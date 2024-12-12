enum UsageType {
  physicalVerification('physical_verification'),
  digitalVerification('digital_verification'),
  addressBook('address_book');

  final String description;

  const UsageType(this.description);

  @override
  String toString() => description;
}
