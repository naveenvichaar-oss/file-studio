sealed class AppError {
  final String message;
  final Object? cause;
  const AppError(this.message, [this.cause]);

  @override
  String toString() => message;
}

class StoragePermissionDeniedError extends AppError {
  const StoragePermissionDeniedError([super.message = 'स्टोरेज की अनुमति नहीं मिली (Permission Denied)']);
}

class FileNotFoundAppError extends AppError {
  const FileNotFoundAppError([super.message = 'फ़ाइल नहीं मिली (File Not Found)']);
}

class FileReadError extends AppError {
  const FileReadError(String path, [Object? cause])
      : super('फ़ाइल पढ़ने में त्रुटि: $path', cause);
}

class FileWriteError extends AppError {
  const FileWriteError(String path, [Object? cause])
      : super('फ़ाइल सेव करने में त्रुटि: $path', cause);
}

class FileDeleteError extends AppError {
  const FileDeleteError(String path, [Object? cause])
      : super('फ़ाइल हटाने में त्रुटि: $path', cause);
}

class FileValidationMismatchError extends AppError {
  const FileValidationMismatchError([super.message = 'सेव करने के बाद डेटा मिलान विफल रहा']);
}

class LargeFileStreamingError extends AppError {
  const LargeFileStreamingError([super.message = 'बड़ी फ़ाइल (>5MB) सिर्फ़ पढ़ने के मोड में खोली जा सकती है']);
}

