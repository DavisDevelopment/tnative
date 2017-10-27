package tannus.async;

enum Either<X, Y> {
    Left(x : X);
    Right(y : Y);
}
