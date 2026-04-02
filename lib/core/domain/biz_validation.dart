class BizValidation<T extends Enum> {
  const BizValidation.ok() : isValid = true, errorCode = null;

  const BizValidation.fail(this.errorCode) : isValid = false;

  final bool isValid;
  final T? errorCode;
}
