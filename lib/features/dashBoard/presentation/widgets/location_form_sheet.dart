import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/common/helper/show_message.dart';
// Import style is not cosmetic here. `di_container.config.dart` registers the
// use cases under `package:` URIs, and a type reached through a different URI is
// a different type to both the analyzer and `GetIt` — so a relative import of a
// use case would compile and then fail to resolve at run time. The models come
// the same way, because the use cases return them.
//
// `DashboardBloc` is the exception: `dashboard_page.dart` imports it
// relatively, and this sheet is handed the instance that file holds, so it has
// to resolve the bloc the same way that file does.
import 'package:trydos/features/dashBoard/data/models/get_shop_locations_model.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_location_form_countries_usecase.dart';
import 'package:trydos/features/dashBoard/domain/useCase/get_shop_location_for_edit_usecase.dart';
import '../bloc/dashBoard_bloc.dart';
import 'package:trydos/features/dashBoard/presentation/widgets/display_text_sanitizer.dart';
import 'package:trydos/core/use_case/use_case.dart';
import 'package:trydos/generated/locale_keys.g.dart';

/// The add / edit form, as a sheet over the list.
///
/// It lives in its own file rather than in `dashboard_page.dart`, which is
/// already past 3,600 lines.
///
/// **This form owns its two reads.** The create form's country list and the
/// load-for-edit record are fetched here, through the use cases directly, and
/// held in this widget's own state. They are deliberately not put on
/// `DashBoardState`: both belong to one open sheet, nothing else renders from
/// them, and `DashboardBloc` is an app-wide singleton that is never disposed —
/// a location record parked on it would outlive every screen that could use it.
/// The three **writes** still go through the bloc, because they change the list
/// the tab is showing.
class LocationFormSheet extends StatefulWidget {
  /// `null` opens the add form. Non-null opens the edit form for that row.
  ///
  /// Only the id is read from it — every value shown is filled from the
  /// load-for-edit response, so there is exactly one prefill source.
  final ShopLocationModel? existing;

  /// Passed down so the create / update handler can refresh the list itself.
  final bool canRead;

  /// Passed explicitly: a modal route does not inherit the tab's providers.
  final DashboardBloc bloc;

  const LocationFormSheet({
    Key? key,
    required this.existing,
    required this.canRead,
    required this.bloc,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required DashboardBloc bloc,
    required bool canRead,
    ShopLocationModel? existing,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => BlocProvider<DashboardBloc>.value(
        value: bloc,
        child: LocationFormSheet(
          existing: existing,
          canRead: canRead,
          bloc: bloc,
        ),
      ),
    );
  }

  @override
  State<LocationFormSheet> createState() => _LocationFormSheetState();
}

class _LocationFormSheetState extends State<LocationFormSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// The contract's published limit for `name`. The rest of the field limits
  /// are unpublished, so nothing beyond this is assumed.
  static const int _kNameMaxLength = 255;

  List<ShopLocationCountry> _countries = const <ShopLocationCountry>[];
  int? _selectedCountryId;

  /// The coordinates the record already had. They are never shown and never
  /// editable, and they travel back out untouched so an edit cannot drop them
  /// (AC-34).
  double? _latitude;
  double? _longitude;

  bool _loading = true;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// One call per form:
  ///
  ///   * **edit** — load-for-edit returns the record *and* its country list, so
  ///     a member who may only update never touches the create-gated lookups
  ///     call;
  ///   * **add** — the create lookups call, which needs `CREATE_LOCATION`.
  Future<void> _loadFormData() async {
    if (_isEdit) {
      final int? id = widget.existing?.id;
      if (id == null || id <= 0) {
        _closeOnFailedLoad();
        return;
      }
      final result = await GetIt.I<GetShopLocationForEditUseCase>()(
        GetShopLocationForEditParams(id: id),
      );
      if (!mounted) return;
      result.fold((l) => _closeOnFailedLoad(), (r) {
        if (r.success == false || r.location == null) {
          _closeOnFailedLoad();
          return;
        }
        _applyPrefill(r.location!, r.countries);
      });
      return;
    }

    final result = await GetIt.I<GetLocationFormCountriesUseCase>()(NoParams());
    if (!mounted) return;
    result.fold(
      (l) {
        // AC-33: the failure of this call is confined to the form. The list
        // behind it is untouched, and the empty picker below carries this
        // screen's own words — never backend text.
        setState(() {
          _loading = false;
          _countries = const <ShopLocationCountry>[];
        });
      },
      (r) {
        setState(() {
          _loading = false;
          _countries = r.countries;
        });
      },
    );
  }

  /// The single prefill, from the load-for-edit response only.
  ///
  /// **Direction-control characters are stripped here, on the prefill.** The
  /// text controllers are not filtered afterwards: what the member types or
  /// pastes stands, keystroke by keystroke, and the save sends what the fields
  /// hold. That is what makes the AC-29 check performable through the app, and
  /// the residual it leaves — a member can save a hostile name — is accepted
  /// explicitly in the plan's Out of scope.
  void _applyPrefill(
    ShopLocationModel record,
    List<ShopLocationCountry> countries,
  ) {
    setState(() {
      _loading = false;
      _countries = countries;
      _nameController.text = stripDirectionControls(record.name);
      _addressController.text = stripDirectionControls(record.address);
      _selectedCountryId = record.country?.id;
      _latitude = record.latitude;
      _longitude = record.longitude;
    });
  }

  /// A failed open closes the form and reloads the list — on **any** failure,
  /// not on a `404`. Every failure reaches this layer flattened to a 400, so a
  /// deleted record, another shop's record and a refused one are
  /// indistinguishable here. A reload after a failed open is not an error
  /// state: the list simply comes back current. One failed open triggers at
  /// most one reload, and no retry loop.
  void _closeOnFailedLoad() {
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.bloc.add(GetShopLocationsEvent(canRead: widget.canRead));
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCountryId == null) {
      showMessage(LocaleKeys.locations_country_is_required.tr(), hasError: true);
      return;
    }

    // Trimmed only — nothing else is done to what the member typed.
    final String name = _nameController.text.trim();
    final String address = _addressController.text.trim();

    if (_isEdit) {
      widget.bloc.add(
        UpdateShopLocationEvent(
          id: widget.existing!.id!,
          name: name,
          countryId: _selectedCountryId!,
          address: address.isEmpty ? null : address,
          latitude: _latitude,
          longitude: _longitude,
          canRead: widget.canRead,
        ),
      );
    } else {
      widget.bloc.add(
        CreateShopLocationEvent(
          name: name,
          countryId: _selectedCountryId!,
          address: address.isEmpty ? null : address,
          latitude: null,
          longitude: null,
          canRead: widget.canRead,
        ),
      );
    }
  }

  String? _validateName(String? value) {
    final String text = (value ?? '').trim();
    if (text.isEmpty) return LocaleKeys.location_name_is_required.tr();
    if (text.length > _kNameMaxLength) {
      return LocaleKeys.locations_name_too_long.tr();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<DashboardBloc, DashBoardState>(
      // Only the write status matters here. Without this the sheet would react
      // to every emission from all eleven tabs.
      listenWhen: (previous, current) =>
          previous.locationWriteStatus != current.locationWriteStatus,
      listener: (context, state) {
        // A successful save closes the form. On a failure the form stays open
        // and the member's input is still there (AC-14); the backend's own
        // words, when they reach the app at all, arrive through the shared
        // error toast outside this form.
        if (state.locationWriteStatus == LocationWriteStatus.success) {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _buildForm(context),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isEdit
                      ? LocaleKeys.locations_edit_title.tr()
                      : LocaleKeys.locations_add.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1D1D1D),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _nameController,
            validator: _validateName,
            // No `TextInputFormatter` and no `maxLength`: capping an editable
            // field would truncate a real name and write the truncation back on
            // the next save. The length is checked at validation instead.
            decoration: InputDecoration(
              labelText: LocaleKeys.location_name.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _addressController,
            maxLines: 2,
            // The address is optional and its absence never blocks a save
            // (AC-8) — so it has no validator.
            decoration: InputDecoration(
              labelText: LocaleKeys.location_address.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          if (_countries.isEmpty)
            // This screen's own words, never backend text.
            Text(
              LocaleKeys.locations_no_countries.tr(),
              style: const TextStyle(color: Color(0xff8D8D8D)),
            )
          else
            DropdownButtonFormField<int>(
              value: _selectedCountryId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: LocaleKeys.locations_country.tr(),
                border: const OutlineInputBorder(),
              ),
              hint: Text(LocaleKeys.locations_select_country.tr()),
              items: _countries
                  .where((ShopLocationCountry c) => c.id != null)
                  .map(
                    (ShopLocationCountry c) => DropdownMenuItem<int>(
                      value: c.id,
                      // Backend text: shown as plain text, sanitized once here.
                      child: Text(
                        sanitizeForDisplay(c.displayName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (int? value) =>
                  setState(() => _selectedCountryId = value),
            ),

          const SizedBox(height: 8),
          // Coordinates are neither shown nor editable. An edit preserves the
          // ones a record already has.
          if (_isEdit && (_latitude != null || _longitude != null))
            Text(
              LocaleKeys.locations_coordinates_kept.tr(),
              style: const TextStyle(fontSize: 12, color: Color(0xff8D8D8D)),
            ),

          const SizedBox(height: 20),
          BlocBuilder<DashboardBloc, DashBoardState>(
            buildWhen: (previous, current) =>
                previous.locationWriteStatus != current.locationWriteStatus,
            builder: (context, state) {
              // Disabled while in flight, so two rapid taps create only one
              // location (AC-10). The bloc's `droppable()` transformer backs
              // the same rule underneath.
              final bool inFlight =
                  state.locationWriteStatus == LocationWriteStatus.inFlight;
              return ElevatedButton(
                onPressed: inFlight || _countries.isEmpty ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff3D3D3D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: inFlight
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(LocaleKeys.save.tr()),
              );
            },
          ),
        ],
      ),
    );
  }
}
