class ApiResponse {
  constructor(statusCode, message, data = null, errors = []) {
    this.statusCode = statusCode;
    this.success = statusCode < 400; // success = true for 2xx
    this.message = message;
    this.data = data;
    this.errors = errors;
  }
}

module.exports=ApiResponse;