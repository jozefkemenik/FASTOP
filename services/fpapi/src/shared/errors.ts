import { HttpStatusCode } from 'axios'

export class HttpError extends Error {
    constructor(public httpStatus: number, message: string) {
        super(message)
    }
}

export class BadRequestError extends HttpError {
    constructor(message: string) {
        super(HttpStatusCode.BadRequest, message)
    }
}
