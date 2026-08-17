module MessageData
  RECORD_NOT_FOUND = { message: "Record not found", status: 404 }
  RECORD_IS_EXISTED = { message: "Record is already in db", status: :conflict }
  RECORD_IS_UNAVAILABLE = { message: "Record is unavailable", status: :unprocessable_entity }
  UNAUTHORIZED = { message: "Unauthorized", status: :unauthorized }
  REQUEST_FAILED = { message: "Request failed", status: :request_failed }
  ACCESS_DENIED = { message: "Access denied", status: 403 }
end
