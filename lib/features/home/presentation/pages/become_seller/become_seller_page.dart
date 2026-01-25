import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mime_type/mime_type.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:trydos/core/utils/extensions/build_context.dart';
import 'package:trydos/features/app/app_widgets/app_text_field.dart';
import 'package:trydos/features/dashBoard/presentation/bloc/dashBoard_bloc.dart';
import 'package:trydos/features/dashBoard/domain/useCase/update_vendor_request_usecase.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trydos/features/home/presentation/pages/become_seller/location_picker_page.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_bloc.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_event.dart';
import 'package:trydos/features/home/presentation/manager/homeBloc/home_state.dart';
import 'package:trydos/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:trydos/core/domin/repositories/prefs_repository.dart';
import 'package:trydos/service/language_service.dart';

// Document Type Enum
enum DocumentType {
  identity('identity'),
  passport('passport'),
  commercialLicense('commercial_license'),
  taxCertificate('tax_certificate'),
  bankStatement('bank_statement'),
  addressProof('address_proof'),
  authorizationLetter('authorization_letter');

  final String value;
  const DocumentType(this.value);
}

class BecomeSellerPage extends StatefulWidget {
  const BecomeSellerPage({super.key});

  @override
  State<BecomeSellerPage> createState() => _BecomeSellerPageState();
}

class _BecomeSellerPageState extends State<BecomeSellerPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Personal Details Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  // Shop Information Controllers
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();

  // Location Details Controllers
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _locationAddressController =
      TextEditingController();
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  // Documents
  DocumentType? _selectedDocumentType;
  String? _documentFilePath;
  String? _documentFileName;
  String? _documentKey; // Store the key from upload response

  bool _isLoading = false;
  bool _isLoadingMap = false;
  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;

  // Store user's registered phone number for validation
  String? _userRegisteredPhone;

  // Store vendor request ID if exists
  int? _vendorRequestId;

  @override
  void initState() {
    super.initState();
    // Load phone number from SharedPreferences for validation only
    final prefsRepository = GetIt.I<PrefsRepository>();
    String phoneNumber = prefsRepository.myPhoneNumber ?? '';
    _userRegisteredPhone = phoneNumber.replaceAll("+", "").trim();

    // Reset state and request existing vendor request
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    // Reset states to init before requesting data
    dashboardBloc.add(ResetVendorRequestStatesEvent());
    dashboardBloc.add(GetVendorRequestEvent());

    // Add listeners to all controllers to update button state
    _firstNameController.addListener(_updateFormState);
    _lastNameController.addListener(_updateFormState);
    _emailController.addListener(_updateFormState);
    _phoneController.addListener(_updateFormState);
    _passwordController.addListener(_updateFormState);
    _repeatPasswordController.addListener(_updateFormState);
    _shopNameController.addListener(_updateFormState);
    _shopAddressController.addListener(_updateFormState);
    _locationNameController.addListener(_updateFormState);
    _locationAddressController.addListener(_updateFormState);
  }

  void _updateFormState() {
    setState(() {
      // This will trigger rebuild and update button state
    });
  }

  @override
  void dispose() {
    // Remove listeners
    _firstNameController.removeListener(_updateFormState);
    _lastNameController.removeListener(_updateFormState);
    _emailController.removeListener(_updateFormState);
    _phoneController.removeListener(_updateFormState);
    _passwordController.removeListener(_updateFormState);
    _repeatPasswordController.removeListener(_updateFormState);
    _shopNameController.removeListener(_updateFormState);
    _shopAddressController.removeListener(_updateFormState);
    _locationNameController.removeListener(_updateFormState);
    _locationAddressController.removeListener(_updateFormState);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _locationNameController.dispose();
    _locationAddressController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    // Check all required text fields
    final allTextFieldsFilled =
        _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _shopNameController.text.trim().isNotEmpty &&
        _shopAddressController.text.trim().isNotEmpty &&
        _locationNameController.text.trim().isNotEmpty &&
        _locationAddressController.text.trim().isNotEmpty;

    if (!allTextFieldsFilled) {
      return false;
    }

    // Check field length constraints (max 10 characters)
    if (_firstNameController.text.trim().length > 10 ||
        _lastNameController.text.trim().length > 10 ||
        _shopNameController.text.trim().length > 10 ||
        _locationNameController.text.trim().length > 10) {
      return false;
    }

    // Check email format
    if (!_emailController.text.trim().contains('@')) {
      return false;
    }

    // Check document is selected and uploaded
    if (_selectedDocumentType == null || _documentKey == null) {
      return false;
    }

    // Check password validation - password is required in all cases
    final passwordFilled =
        _passwordController.text.trim().isNotEmpty &&
        _repeatPasswordController.text.trim().isNotEmpty;
    final passwordValidLength =
        _passwordController.text.trim().length >= 8 &&
        _repeatPasswordController.text.trim().length >= 8;
    final passwordMatch =
        _passwordController.text.trim() ==
        _repeatPasswordController.text.trim();

    // Password is required in all cases (both update and new submission)
    if (!passwordFilled || !passwordValidLength || !passwordMatch) {
      return false;
    }

    // Check if password fields are partially filled (invalid state)
    final oneFieldFilled =
        _passwordController.text.trim().isNotEmpty ||
        _repeatPasswordController.text.trim().isNotEmpty;
    final bothFieldsFilled =
        _passwordController.text.trim().isNotEmpty &&
        _repeatPasswordController.text.trim().isNotEmpty;

    if (oneFieldFilled && !bothFieldsFilled) {
      return false; // One field filled but not both - invalid
    }

    // All validations passed
    return true;
  }

  Future<void> _pickLocation() async {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    setState(() {
      _isLoadingMap = true;
    });

    // Request country boundaries
    homeBloc.add(const GetCoutryBoundaryByIsoEvent());

    // Wait for the event to complete
    await homeBloc.stream.firstWhere(
      (state) =>
          state.getCountryBoundaryByIsoStatus !=
          GetCountryBoundaryByIsoStatus.loading,
    );

    setState(() {
      _isLoadingMap = false;
    });

    // Check if request was successful
    if (homeBloc.state.getCountryBoundaryByIsoStatus ==
        GetCountryBoundaryByIsoStatus.success) {
      final result = await Navigator.push<LatLng>(
        context,
        MaterialPageRoute(builder: (context) => const LocationPickerPage()),
      );

      if (result != null) {
        setState(() {
          _selectedLocation = result;
          _updateFormState();
          _markers = {
            Marker(
              markerId: const MarkerId('selected_location'),
              position: result,
            ),
          };
        });
        // Move camera to selected location
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(result, 15));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.failed_to_load_map_boundaries.tr()),
          ),
        );
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.single.path != null) {
        setState(() {
          _documentFilePath = result.files.single.path;
          _documentFileName = result.files.single.name;
          _documentKey = null; // Reset key when new file is selected
        });
        _updateFormState();
      } else {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${LocaleKeys.error_picking_file.tr()}: $e')),
        );
      }
    }
  }

  Future<void> _uploadDocument() async {
    if (_documentFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.please_select_a_file_first.tr())),
      );
      return;
    }

    final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    final file = File(_documentFilePath!);
    final fileName = _documentFileName ?? file.path.split('/').last;
    final mimeType = mime(fileName) ?? 'application/octet-stream';

    dashboardBloc.add(
      UploadDocumentEvent(filePath: _documentFilePath!, mimeType: mimeType),
    );
  }

  Future<void> _submitForm() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check all required fields
    String? errorMessage;

    if (_firstNameController.text.trim().isEmpty) {
      errorMessage = LocaleKeys.first_name_is_required.tr();
    } else if (_firstNameController.text.trim().length > 10) {
      errorMessage = LocaleKeys.field_must_not_exceed_10_characters.tr();
    } else if (_lastNameController.text.trim().isEmpty) {
      errorMessage = LocaleKeys.last_name_is_required.tr();
    } else if (_lastNameController.text.trim().length > 10) {
      errorMessage = LocaleKeys.field_must_not_exceed_10_characters.tr();
    } else if (_emailController.text.trim().isEmpty) {
      errorMessage = LocaleKeys.email_is_required.tr();
    } else if (!_emailController.text.trim().contains('@')) {
      errorMessage = LocaleKeys.invalid_email_format.tr();
    } else if (_phoneController.text.trim().isEmpty) {
      errorMessage = LocaleKeys.phone_is_required.tr();
    } else if (_userRegisteredPhone != null &&
        _userRegisteredPhone!.isNotEmpty) {
      // Check if phone number matches registered user's phone
      final enteredPhone = _phoneController.text
          .trim()
          .replaceAll("+", "")
          .trim();
      final registeredPhone = _userRegisteredPhone!.replaceAll("+", "").trim();
      if (enteredPhone == registeredPhone) {
        errorMessage = LocaleKeys.phone_cannot_be_same_as_registered.tr();
      }
    } else if (_passwordController.text.trim().isEmpty) {
      errorMessage = LocaleKeys.password_is_required.tr();
    } else if (_passwordController.text.trim().length < 8) {
      errorMessage = LocaleKeys.password_must_be_at_least_8_characters.tr();
    } else if (_repeatPasswordController.text.trim().isEmpty) {
      errorMessage = LocaleKeys.repeat_password_is_required.tr();
    } else if (_passwordController.text != _repeatPasswordController.text) {
      errorMessage = LocaleKeys.passwords_do_not_match.tr();
    } else if (_shopNameController.text.trim().isEmpty) {
      errorMessage = LocaleKeys.shop_name_is_required.tr();
    } else if (_shopNameController.text.trim().length > 10) {
      errorMessage = LocaleKeys.field_must_not_exceed_10_characters.tr();
    } else if (_shopAddressController.text.trim().isEmpty) {
      errorMessage = LocaleKeys.shop_address_is_required.tr();
    } else if (_locationNameController.text.trim().isEmpty) {
      errorMessage = LocaleKeys.location_name_is_required.tr();
    } else if (_locationNameController.text.trim().length > 10) {
      errorMessage = LocaleKeys.field_must_not_exceed_10_characters.tr();
    } else if (_locationAddressController.text.trim().isEmpty) {
      errorMessage = LocaleKeys.location_address_is_required.tr();
    } else if (_selectedDocumentType == null) {
      errorMessage = LocaleKeys.document_type_is_required.tr();
    } else if (_documentFilePath == null) {
      errorMessage = LocaleKeys.please_upload_a_document.tr();
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    // Get required data
    final prefsRepository = GetIt.I<PrefsRepository>();
    final countryIso = prefsRepository.userCountryIsAvailable == 1
        ? prefsRepository.userChoosedCountryIso
        : prefsRepository.countryIso;

    final languageCode = LanguageService.languageCode == 'ar'
        ? (LanguageService.isKurdish ? 'ku' : 'ar')
        : LanguageService.languageCode;

    // Get currency code from HomeBloc or use default
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    final currencyCode =
        homeBloc.state.getCurrencyForCountryModel?.data?.currency?.code ??
        'USD';

    // Prepare document
    if (_documentKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.please_upload_a_document.tr())),
      );
      return;
    }

    // Prepare documents array
    final documents = [
      DocumentParams(type: _selectedDocumentType!.value, path: _documentKey!),
    ];

    // Create params
    final params = SubmitVendorRequestParams(
      fName: _firstNameController.text.trim(),
      lName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      repeatPassword: _repeatPasswordController.text.trim(),
      currencyCode: currencyCode,
      countryIso: countryIso ?? 'USD',
      languageCode: languageCode,
      shopName: _shopNameController.text.trim(),
      shopAddress: _shopAddressController.text.trim(),
      locationCountryIso: countryIso ?? 'USD',
      locationName: _locationNameController.text.trim(),
      locationAddress: _locationAddressController.text.trim(),
      latitude: _selectedLocation?.latitude,
      longitude: _selectedLocation?.longitude,
      documents: documents,
    );

    // Submit or Update via Bloc
    final dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    if (_vendorRequestId != null) {
      // Update existing request
      dashboardBloc.add(
        UpdateVendorRequestEvent(
          params: UpdateVendorRequestParams(
            vendorRequestId: _vendorRequestId!,
            fName: params.fName,
            lName: params.lName,
            email: params.email,
            phone: params.phone,
            password: params.password,
            repeatPassword: params.repeatPassword,
            currencyCode: params.currencyCode,
            countryIso: params.countryIso,
            languageCode: params.languageCode,
            shopName: params.shopName,
            shopAddress: params.shopAddress,
            locationCountryIso: params.locationCountryIso,
            locationName: params.locationName,
            locationAddress: params.locationAddress,
            latitude: params.latitude,
            longitude: params.longitude,
            documents: params.documents,
          ),
        ),
      );
    } else {
      // Submit new request
      dashboardBloc.add(SubmitVendorRequestEvent(params: params));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashBoardState>(
      listener: (context, state) {
        if (state.uploadDocumentStatus == UploadDocumentStatus.success) {
          setState(() {
            _documentKey = state.uploadedDocumentKey;
          });
          _updateFormState();
        }
        if (state.getVendorRequestStatus == GetVendorRequestStatus.success) {
          final vendorRequest = state.vendorRequest;
          if (vendorRequest != null) {
            // Temporarily remove listeners to prevent _updateFormState from being called
            _firstNameController.removeListener(_updateFormState);
            _lastNameController.removeListener(_updateFormState);
            _emailController.removeListener(_updateFormState);
            _phoneController.removeListener(_updateFormState);
            _passwordController.removeListener(_updateFormState);
            _repeatPasswordController.removeListener(_updateFormState);
            _shopNameController.removeListener(_updateFormState);
            _shopAddressController.removeListener(_updateFormState);
            _locationNameController.removeListener(_updateFormState);
            _locationAddressController.removeListener(_updateFormState);

            setState(() {
              _vendorRequestId = vendorRequest.id;
              _firstNameController.text = vendorRequest.name ?? '';
              _lastNameController.text = vendorRequest.lName ?? '';
              _emailController.text = vendorRequest.email ?? '';
              _phoneController.text = vendorRequest.phone ?? '';
              _shopNameController.text = vendorRequest.shopName ?? '';
              _shopAddressController.text = vendorRequest.shopAddress ?? '';
              _locationNameController.text = vendorRequest.locationName ?? '';
              _locationAddressController.text =
                  vendorRequest.locationAddress ?? '';

              if (vendorRequest.latitude != null &&
                  vendorRequest.longitude != null) {
                final lat = double.tryParse(vendorRequest.latitude ?? '');
                final lng = double.tryParse(vendorRequest.longitude ?? '');
                if (lat != null && lng != null) {
                  _selectedLocation = LatLng(lat, lng);
                  _markers = {
                    Marker(
                      markerId: const MarkerId('selected_location'),
                      position: _selectedLocation!,
                    ),
                  };
                  // Move camera to selected location
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
                  );
                }
              }

              if (vendorRequest.documents != null &&
                  vendorRequest.documents!.isNotEmpty) {
                final doc = vendorRequest.documents!.first;
                _documentKey = doc.path;
                _documentFileName = doc.path?.split('/').last;

                // Map document type
                switch (doc.type) {
                  case 'identity':
                    _selectedDocumentType = DocumentType.identity;
                    break;
                  case 'passport':
                    _selectedDocumentType = DocumentType.passport;
                    break;
                  case 'commercial_license':
                    _selectedDocumentType = DocumentType.commercialLicense;
                    break;
                  case 'tax_certificate':
                    _selectedDocumentType = DocumentType.taxCertificate;
                    break;
                  case 'bank_statement':
                    _selectedDocumentType = DocumentType.bankStatement;
                    break;
                  case 'address_proof':
                    _selectedDocumentType = DocumentType.addressProof;
                    break;
                  case 'authorization_letter':
                    _selectedDocumentType = DocumentType.authorizationLetter;
                    break;
                }
              }
            });

            // Re-add listeners after filling form
            _firstNameController.addListener(_updateFormState);
            _lastNameController.addListener(_updateFormState);
            _emailController.addListener(_updateFormState);
            _phoneController.addListener(_updateFormState);
            _passwordController.addListener(_updateFormState);
            _repeatPasswordController.addListener(_updateFormState);
            _shopNameController.addListener(_updateFormState);
            _shopAddressController.addListener(_updateFormState);
            _locationNameController.addListener(_updateFormState);
            _locationAddressController.addListener(_updateFormState);

            // Force rebuild to update button state
            setState(() {});
          }
        }
        if (state.submitVendorRequestStatus ==
            SubmitVendorRequestStatus.success) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            Navigator.pop(context);
          }
        } else if (state.submitVendorRequestStatus ==
            SubmitVendorRequestStatus.failure) {
          setState(() {
            _isLoading = false;
          });
        } else if (state.submitVendorRequestStatus ==
            SubmitVendorRequestStatus.loading) {
          setState(() {
            _isLoading = true;
          });
        }
        if (state.updateVendorRequestStatus ==
            UpdateVendorRequestStatus.success) {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            Navigator.pop(context);
          }
        } else if (state.updateVendorRequestStatus ==
            UpdateVendorRequestStatus.failure) {
          setState(() {
            _isLoading = false;
          });
        } else if (state.updateVendorRequestStatus ==
            UpdateVendorRequestStatus.loading) {
          setState(() {
            _isLoading = true;
          });
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Center(
                  child: Text(
                    LocaleKeys.become_a_seller_at_trydos.tr(),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Form Content with Scroll
              Flexible(
                child: BlocBuilder<DashboardBloc, DashBoardState>(
                  buildWhen: (previous, current) =>
                      previous.getVendorRequestStatus !=
                      current.getVendorRequestStatus,
                  builder: (context, state) {
                    if (state.getVendorRequestStatus ==
                        GetVendorRequestStatus.loading) {
                      return _buildShimmerLoading();
                    }
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20.w,
                        right: 20.w,
                        bottom: 20.h,
                      ),
                      child: Column(
                        children: [
                          _buildPersonalDetailsStep(),
                          SizedBox(height: 30.h),
                          _buildShopInformationStep(),
                          SizedBox(height: 30.h),
                          _buildLocationDetailsStep(),
                          SizedBox(height: 30.h),
                          _buildDocumentsStep(),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsStep() {
    return Column(
      children: [
        Text(
          LocaleKeys.personal_details.tr(),
          style: context.textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        _buildTextField(
          controller: _firstNameController,
          label: LocaleKeys.first_name.tr(),
          hint: 'John',
          maxLength: 10,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocaleKeys.the_field_must_not_be_empty.tr();
            }
            if (value.trim().length > 10) {
              return LocaleKeys.field_must_not_exceed_10_characters.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _lastNameController,
          label: LocaleKeys.last_name.tr(),
          hint: 'Doe',
          maxLength: 10,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocaleKeys.the_field_must_not_be_empty.tr();
            }
            if (value.trim().length > 10) {
              return LocaleKeys.field_must_not_exceed_10_characters.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _emailController,
          label: LocaleKeys.email.tr(),
          hint: 'example@mail.com',
          textInputType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocaleKeys.the_field_must_not_be_empty.tr();
            }
            if (!value.contains('@')) {
              return LocaleKeys.invalid_email.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _phoneController,
          label: LocaleKeys.phone.tr(),
          hint: '+1 234...',
          textInputType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocaleKeys.the_field_must_not_be_empty.tr();
            }
            // Check if phone number matches registered user's phone
            if (_userRegisteredPhone != null &&
                _userRegisteredPhone!.isNotEmpty) {
              final enteredPhone = value.trim().replaceAll("+", "").trim();
              final registeredPhone = _userRegisteredPhone!
                  .replaceAll("+", "")
                  .trim();
              if (enteredPhone == registeredPhone) {
                return LocaleKeys.phone_cannot_be_same_as_registered.tr();
              }
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _passwordController,
          label: LocaleKeys.password.tr(),
          hint: '******',
          obscure: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocaleKeys.the_field_must_not_be_empty.tr();
            }
            if (value.length < 8) {
              return LocaleKeys.password_must_be_at_least_8_characters.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _repeatPasswordController,
          label: LocaleKeys.repeat_password.tr(),
          hint: '******',
          obscure: _obscureRepeatPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRepeatPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _obscureRepeatPassword = !_obscureRepeatPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocaleKeys.the_field_must_not_be_empty.tr();
            }
            if (value != _passwordController.text) {
              return LocaleKeys.passwords_do_not_match.tr();
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildShopInformationStep() {
    return Column(
      children: [
        Text(
          LocaleKeys.shop_information.tr(),
          style: context.textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        _buildTextField(
          controller: _shopNameController,
          label: LocaleKeys.shop_name.tr(),
          hint: 'My Shop',
          maxLength: 10,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocaleKeys.the_field_must_not_be_empty.tr();
            }
            if (value.trim().length > 10) {
              return LocaleKeys.field_must_not_exceed_10_characters.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _shopAddressController,
          label: LocaleKeys.shop_address.tr(),
          hint: 'Street 1',
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocaleKeys.the_field_must_not_be_empty.tr();
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationDetailsStep() {
    return Column(
      children: [
        Text(
          LocaleKeys.location_details.tr(),
          style: context.textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        _buildTextField(
          controller: _locationNameController,
          label: LocaleKeys.location_name.tr(),
          hint: 'Warehouse',
          maxLength: 10,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocaleKeys.the_field_must_not_be_empty.tr();
            }
            if (value.trim().length > 10) {
              return LocaleKeys.field_must_not_exceed_10_characters.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _locationAddressController,
          label: LocaleKeys.location_address.tr(),
          hint: 'Full Address',
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return LocaleKeys.the_field_must_not_be_empty.tr();
            }
            return null;
          },
        ),
        SizedBox(height: 20.h),
        // Map Container
        GestureDetector(
          onTap: _isLoadingMap ? null : _pickLocation,
          child: Container(
            height: 60.h,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target:
                          _selectedLocation ??
                          const LatLng(
                            25.276987,
                            51.520008,
                          ), // Default to Qatar
                      zoom: _selectedLocation != null ? 15 : 10,
                    ),
                    markers: _markers,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    onTap: (LatLng position) {
                      if (!_isLoadingMap) {
                        _pickLocation();
                      }
                    },
                  ),
                  if (_isLoadingMap)
                    Container(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                              // ignore: deprecated_member_use
                              Colors.grey[800]?.withOpacity(0.8) ??
                              Colors.grey[800]!,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.send, size: 16.sp, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text(
                              LocaleKeys.locate_your_location_on_map.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      children: [
        Text(
          LocaleKeys.documents.tr(),
          style: context.textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        if (_documentFilePath == null)
          Text(
            LocaleKeys.no_documents_uploaded.tr(),
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
            textAlign: TextAlign.center,
          ),
        SizedBox(height: 20.h),
        _buildDocumentTypeDropdown(),
        SizedBox(height: 16.h),
        Column(
          children: [
            Text(
              LocaleKeys.choose_file.tr(),
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _pickDocument,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Text(
                      LocaleKeys.choose_file.tr(),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14.sp,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _documentFileName ?? LocaleKeys.no_file_chosen.tr(),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        BlocBuilder<DashboardBloc, DashBoardState>(
          buildWhen: (previous, current) =>
              previous.uploadDocumentStatus != current.uploadDocumentStatus,
          builder: (context, state) {
            final isUploading =
                state.uploadDocumentStatus == UploadDocumentStatus.loading;
            final isUploaded = _documentKey != null;

            // Disable button if: no file selected, uploading, or already uploaded
            final isButtonDisabled =
                _documentFilePath == null || isUploading || isUploaded;

            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isButtonDisabled ? null : _uploadDocument,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonDisabled
                          ? Colors.grey[400]
                          : Colors.blue,
                      disabledBackgroundColor: Colors.grey[400],
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: isUploading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            LocaleKeys.upload_document.tr(),
                            style: TextStyle(
                              color: isButtonDisabled
                                  ? Colors.grey[600]
                                  : Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (isUploaded)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      LocaleKeys.document_uploaded_successfully.tr(),
                      style: TextStyle(color: Colors.green, fontSize: 12.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Get translated text for document type
  String _getDocumentTypeText(DocumentType type) {
    switch (type) {
      case DocumentType.identity:
        return LocaleKeys.document_type_identity.tr();
      case DocumentType.passport:
        return LocaleKeys.document_type_passport.tr();
      case DocumentType.commercialLicense:
        return LocaleKeys.document_type_commercial_license.tr();
      case DocumentType.taxCertificate:
        return LocaleKeys.document_type_tax_certificate.tr();
      case DocumentType.bankStatement:
        return LocaleKeys.document_type_bank_statement.tr();
      case DocumentType.addressProof:
        return LocaleKeys.document_type_address_proof.tr();
      case DocumentType.authorizationLetter:
        return LocaleKeys.document_type_authorization_letter.tr();
    }
  }

  Widget _buildDocumentTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.document_type.tr(),
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonHideUnderline(
          child: DropdownButton2<DocumentType>(
            isExpanded: true,
            hint: Text(
              LocaleKeys.document_type_hint.tr(),
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            items: DocumentType.values.map((DocumentType type) {
              return DropdownMenuItem<DocumentType>(
                value: type,
                child: Text(
                  _getDocumentTypeText(type),
                  style: TextStyle(fontSize: 14.sp, color: Colors.black87),
                ),
              );
            }).toList(),
            value: _selectedDocumentType,
            onChanged: (DocumentType? newValue) {
              setState(() {
                _selectedDocumentType = newValue;
              });
              _updateFormState();
            },
            buttonStyleData: ButtonStyleData(
              height: 50.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.white,
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 300.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: List.generate(8, (index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? textInputType,
    bool obscure = false,
    bool readOnly = false,
    int? maxLines,
    int? maxLength,
    Widget? suffixIcon,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        AppTextField(
          controller: controller,
          hintText: hint,
          textInputType: textInputType,
          obscure: obscure,
          readOnly: readOnly,
          maxLines: obscure ? 1 : (maxLines ?? 1),
          validator: validator,
          autoValidateMode: validator != null
              ? AutovalidateMode.onUserInteraction
              : null,
          onTap: onTap,
          suffixIcon: suffixIcon,
          textStyle: context.textTheme.bodyMedium?.copyWith(
            color: Colors.black,
            fontSize: 14.sp,
          ),
          hintTextStyle: context.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[400],
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  LocaleKeys.cancel.tr(),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid()
                      ? Colors.blue
                      : Colors.grey[400],
                  disabledBackgroundColor: Colors.grey[400],
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _vendorRequestId != null
                            ? LocaleKeys.update.tr()
                            : LocaleKeys.submit.tr(),
                        style: TextStyle(
                          color: _isFormValid()
                              ? Colors.white
                              : Colors.grey[600],
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
