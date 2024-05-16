/* eslint-disable @typescript-eslint/no-explicit-any */

type HandlerFunction = (propertyName: string, error: any, ctx: any) => void

// Decorator factory function
export const catchError = (errorType: any, handler: HandlerFunction): any => {
    return (target: any, propertyKey: string, descriptor: PropertyDescriptor) => {
        // Method decorator
        if (descriptor) {
            return _generateDescriptor(propertyKey, descriptor, errorType, handler)
        }
        // Class decorator
        else {
            // Iterate over class properties except constructor
            for (const propertyName of Reflect.ownKeys(target.prototype).filter(prop => prop !== 'constructor')) {
                const desc = Object.getOwnPropertyDescriptor(target.prototype, propertyName)
                const isMethod = desc.value instanceof Function
                if (!isMethod) continue
                Object.defineProperty(
                    target.prototype, propertyName,
                    _generateDescriptor(propertyName.toString(), desc, errorType, handler)
                )
            }
        }
    }
}

function _generateDescriptor(
    propertyName: string,
    descriptor: PropertyDescriptor,
    errorType: any,
    handler: HandlerFunction
): PropertyDescriptor {
    // Save a reference to the original method
    const originalMethod = descriptor.value

    // Rewrite original method with try/catch wrapper
    descriptor.value = function (...args: any[]) {
        try {
            const result = originalMethod.apply(this, args)

            // Check if method is asynchronous
            if (result && result instanceof Promise) {
                // Return promise
                return result.catch((error: any) => {
                    _handleError(this, propertyName, errorType, handler, error)
                })
            }

            // Return actual result
            return result
        } catch (error) {
            _handleError(this, propertyName, errorType, handler, error)
        }
    }

    return descriptor
}

function _handleError(ctx: any, propertyName: string, errorType: any, handler: HandlerFunction, error: Error) {
    // Check if error is instance of given error type
    if (typeof handler === 'function' && error instanceof errorType) {
        // Run handler with error object and class context
        handler.call(null, propertyName, error, ctx)
    } else {
        // Throw error further
        // Next decorator in chain can catch it
        throw error
    }
}

/* eslint-disable-next-line @typescript-eslint/no-unused-vars */
export const catchAll = (className: string) => catchError(Error, (propertyName, error, ctx) => {
    error.method = `${className}:${propertyName}`
    throw error
})

/* eslint-enable @typescript-eslint/no-explicit-any */
