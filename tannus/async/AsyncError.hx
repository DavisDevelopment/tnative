package tannus.async;

import Type.ValueType;

enum AsyncError<T> {
    @pseudoError
    Interrupt(stop: AsyncInterrupt<T>):AsyncError<T>;

    InvalidValue(value:T, reason:Validator<T>):AsyncError<T>;
}

enum AsyncInterrupt<T> {
/* === Functional Interrupts === */
    IReturn(value: T):AsyncInterrupt<T>;
    IThrow(thrown: T):AsyncInterrupt<T>;
    
/* === Iterator Interrupts === */
    IYield(value: T):AsyncInterrupt<T>;
    IContinue;
    IBreak;
}

enum Validator<T> {
    NotNull():Validator<T>;
    NotEmpty():Validator<T>;
    CheckType(type: TypeValidator):Validator<T>;
    CustomValidator(check: Dynamic->Bool):Validator<T>;

/* === Combinators === */

    ValidatorNot(valid: Validator<T>):Validator<T>;
    ValidatorAnd(l:Validator<T>, r:Validator<T>):Validator<T>;
}

enum TypeValidator {
    TypeIdenticalTo(type: ValueType);
    TypeUnifiesWith(type: ValueType);
    TypeIsAsyncType();
    TypeIsSyncType();

/* === Combinators === */

    TypeNot(operand: TypeValidator);
    TypeAnd(left:TypeValidator, right:TypeValidator);
    TypeOr(left:TypeValidator, right:TypeValidator);
}
