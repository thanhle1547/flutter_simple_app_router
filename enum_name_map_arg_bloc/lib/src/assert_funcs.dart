bool assertRequiredArguments(Map<String, Object>? requiredArguments) {
  if (requiredArguments == null) return true;

  for (final MapEntry<String, Object> item in requiredArguments.entries) {
    if (item.value.toString() == 'dynamic') return false;
  }

  return true;
}
