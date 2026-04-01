import { AsyncLocalStorage } from "node:async_hooks";

type RequestContext = {
  requestId?: string;
};

const requestContextStorage = new AsyncLocalStorage<RequestContext>();

export function setRequestContext(context: RequestContext): void {
  requestContextStorage.enterWith(context);
}

export function getRequestContext(): RequestContext | undefined {
  return requestContextStorage.getStore();
}

export function getRequestId(): string | undefined {
  return getRequestContext()?.requestId;
}
