package tannus.concurrent;

import tannus.concurrent.IWorker;

#if (js && !node)

typedef Worker<I, O> = tannus.concurrent.js.JSWorker<I, O>;

#end

