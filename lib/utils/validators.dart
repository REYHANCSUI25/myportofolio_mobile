String? validateRequired(String? value, String message) {
  return value == null || value.trim().isEmpty ? message : null;
}

String? validateOptionalLink(String? value) {
  final String link = value?.trim() ?? '';
  if (link.isEmpty) {
    return null;
  }
  final Uri? uri = Uri.tryParse(link);
  final bool isWebLink =
      uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.contains('.');
  return isWebLink
      ? null
      : 'Enter a valid link that starts with http:// or https://.';
}

String? validateDateOrder(DateTime? start, DateTime? end) {
  if (start != null && end != null && end.isBefore(start)) {
    return "The end date can't be before the start date.";
  }
  return null;
}
