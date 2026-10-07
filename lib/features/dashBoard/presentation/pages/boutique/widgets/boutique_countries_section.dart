import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:trydos/features/dashBoard/data/models/boutique_edit_model.dart';
import 'package:trydos/generated/locale_keys.g.dart';

import 'boutique_availability_section.dart';

/// Restricted countries: one chip per country from the lookups, labelled with
/// the name the backend gives (spec OQ-7). Empty selection means every country
/// (AC-29). A selected chip has an outline and a light tint, not a checkbox.
class BoutiqueCountriesSection extends StatelessWidget {
  final List<BoutiqueCountryModel> countries;
  final List<String> selected;
  final bool enabled;
  final ValueChanged<String> onToggle;

  const BoutiqueCountriesSection({
    super.key,
    required this.countries,
    required this.selected,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return BoutiqueSectionCard(
      icon: Icons.public,
      title: LocaleKeys.boutique_restricted_countries.tr(),
      subtitle: LocaleKeys.boutique_restricted_countries_hint.tr(),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(4),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final BoutiqueCountryModel country in countries)
                _CountryChip(
                  label: country.name,
                  selected: selected.contains(country.iso),
                  enabled: enabled,
                  onTap: () => onToggle(country.iso),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _CountryChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: selected
            ? BoutiqueColors.primary.withValues(alpha: 0.08)
            : BoutiqueColors.chip,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? BoutiqueColors.primary : Colors.transparent,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected
                    ? BoutiqueColors.text
                    : BoutiqueColors.muted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
