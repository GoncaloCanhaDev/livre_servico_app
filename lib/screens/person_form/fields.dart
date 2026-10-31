part of '../person_form_screen.dart';

/// The profile picture (the new pick, else the saved one) with a camera
/// badge; tap to change it.
class _PhotoButton extends StatelessWidget {
  const _PhotoButton({required this.photo, required this.onTap});

  final ImageProvider? photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photo = this.photo;
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundImage: photo,
              onBackgroundImageError: photo == null ? null : (_, _) {},
              child: photo == null ? const Icon(Icons.person, size: 48) : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Permanência tick-chip (a tag anyone can have, with no permissions).
class _TagsField extends StatelessWidget {
  const _TagsField({required this.permanencia, required this.onPermanencia});

  final bool permanencia;
  final ValueChanged<bool> onPermanencia;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Tags',
        helperText: 'Permanência: responsável quando não há chefia presente',
        border: OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          FilterChip(
            label: const Text('Permanência'),
            selected: permanencia,
            onSelected: onPermanencia,
          ),
        ],
      ),
    );
  }
}

/// Entrada and saída times, each optional.
class _ShiftField extends StatelessWidget {
  const _ShiftField({
    required this.start,
    required this.end,
    required this.onPick,
    required this.onClear,
  });

  /// Minutes after midnight.
  final int? start;
  final int? end;

  /// Called with true for the entrada, false for the saída.
  final ValueChanged<bool> onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    Widget button(bool isStart) {
      final value = isStart ? start : end;
      return Expanded(
        child: OutlinedButton(
          onPressed: () => onPick(isStart),
          child: Text(
            value == null ? (isStart ? 'Entrada' : 'Saída') : timeText(value),
          ),
        ),
      );
    }

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Entrada e saída (opcional)',
        border: OutlineInputBorder(),
      ),
      child: Row(
        children: [
          button(true),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('–'),
          ),
          button(false),
          if (start != null || end != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}

/// A chip per weekday; ticked days are the person's weekly folgas.
class _FolgasField extends StatelessWidget {
  const _FolgasField({required this.folgas, required this.onToggle});

  /// DateTime.weekday values.
  final Set<int> folgas;
  final void Function(int weekday, bool off) onToggle;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Folgas',
        border: OutlineInputBorder(),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (var d = DateTime.monday; d <= DateTime.sunday; d++)
            FilterChip(
              label: Text(weekdayShort[d - 1]),
              showCheckmark: false,
              selected: folgas.contains(d),
              onSelected: (v) => onToggle(d, v),
            ),
        ],
      ),
    );
  }
}

/// The person's ausências (tap to edit, ✕ to remove) and an add button.
class _AusenciasField extends StatelessWidget {
  const _AusenciasField({
    required this.ausencias,
    required this.onEdit,
    required this.onRemove,
  });

  final List<Ausencia> ausencias;

  /// Called with null to add a new one.
  final ValueChanged<Ausencia?> onEdit;
  final ValueChanged<Ausencia> onRemove;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Férias e ausências',
        border: OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final a in ausencias)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(a.tipo.label),
              subtitle: Text(ausenciaRangeText(a)),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => onRemove(a),
              ),
              onTap: () => onEdit(a),
            ),
          TextButton.icon(
            onPressed: () => onEdit(null),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar ausência'),
          ),
        ],
      ),
    );
  }
}

/// One editable field per note, then an empty field whose text becomes a
/// new note on enter or +.
class _NotesField extends StatelessWidget {
  const _NotesField({
    required this.notes,
    required this.newNote,
    required this.onAdd,
    required this.onRemove,
  });

  final List<TextEditingController> notes;
  final TextEditingController newNote;
  final VoidCallback onAdd;
  final ValueChanged<TextEditingController> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final c in notes)
          Padding(
            key: ObjectKey(c),
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              controller: c,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                isDense: true,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => onRemove(c),
                ),
              ),
            ),
          ),
        TextField(
          controller: newNote,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onAdd(),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Nova nota',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAdd,
            ),
          ),
        ),
      ],
    );
  }
}

/// Aniversário: the day and the month, no year (none is kept).
class _BirthdayField extends StatelessWidget {
  const _BirthdayField({
    required this.day,
    required this.month,
    required this.onDay,
    required this.onMonth,
  });

  final int? day;
  final int? month;
  final ValueChanged<int?> onDay;
  final ValueChanged<int?> onMonth;

  static const _months = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', //
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: const InputDecoration(
      labelText: 'Aniversário (opcional)',
      border: OutlineInputBorder(),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 88,
          child: DropdownButtonFormField<int?>(
            initialValue: day,
            decoration: const InputDecoration(labelText: 'Dia'),
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              for (var d = 1; d <= 31; d++)
                DropdownMenuItem(value: d, child: Text('$d')),
            ],
            onChanged: onDay,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int?>(
            initialValue: month,
            decoration: const InputDecoration(labelText: 'Mês'),
            items: [
              const DropdownMenuItem(value: null, child: Text('—')),
              for (var m = 1; m <= 12; m++)
                DropdownMenuItem(value: m, child: Text(_months[m - 1])),
            ],
            onChanged: onMonth,
            validator: (m) {
              final d = day;
              if (d == null || m == null) return null;
              // 29 February is fine (on the 28th outside leap years).
              return d > DateTime(2024, m + 1, 0).day ? 'Dia inválido' : null;
            },
          ),
        ),
      ],
    ),
  );
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.formatted,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final String? formatted;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: context.greyedFill),
      ),
      leading: const Icon(Icons.event_outlined),
      title: Text(label),
      subtitle: Text(formatted ?? 'Não definida'),
      trailing: value == null
          ? const Icon(Icons.chevron_right)
          : IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onClear,
            ),
      onTap: onTap,
    );
  }
}

/// A section title in the form.
class _FormHeading extends StatelessWidget {
  const _FormHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: context.colors.secondary,
        ),
      ),
    );
  }
}
