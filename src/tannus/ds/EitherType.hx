package tannus.ds;

/**
  * Abstract type allowing unification between two unrelated types, implicit casting to/from either type, AND a type-safe way to check which type was provided
  */
abstract EitherType<L, R> (Either<L, R>) {
	/* Constructor Function */
	public inline function new(e : Either<L, R>):Void {
		this = e;
	}

	/**
	  * Which type was provided, as a field
	  */
	public var type(get, never):Either<L, R>;
	private inline function get_type() return this;

	/**
	  * Macro method to more concisely perform an action based on the type of [this]
	  */
	public macro function switchType(self, leftName, rightName, leftAction, rightAction) {
		return macro switch ($self.type) {
			case Left( $leftName ):
				$leftAction;

			case Right( $rightName ):
				$rightAction;
		}
	}

	/**
	  * Cast implicitly to the Left type
	  */
	@:to
	public function toLeft():L {
		switch (type) {
			case Left( lv ):
				return lv;

			case Right( rv ):
				throw 'EitherTypeError: $rv was not the expected value!';
		}
	}

	/**
	  * Cast implicitly to the Right type
	  */
	@:to
	public function toRight():R {
		switch (type) {
			case Right( rv ):
				return rv;

			case Left( lv ):
				throw 'EitherTypeError: $lv was not the expected value!';
		}
	}

	@:from
	public static function fromL<L, R>(v : L):EitherType<L, R> {
		return new EitherType(Either.Left(v));
	}

	@:from
	public static inline function fromR<L, R>(v : R):EitherType<L, R> {
		return new EitherType(Either.Right(v));
	}
}

enum Either<L, R> {
	Left(value : L);
	Right(value : R);
}
