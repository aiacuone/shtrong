/**
 * Call `close` on Escape or on a press outside the popup. Returns the cleanup,
 * so an `$effect` can `return onDismiss(...)` while the popup is open.
 */
export function onDismiss(inside: (target: EventTarget | null) => boolean, close: () => void) {
	const onPointer = (e: PointerEvent) => {
		if (!inside(e.target)) close();
	};
	const onKey = (e: KeyboardEvent) => {
		if (e.key === 'Escape') close();
	};
	document.addEventListener('pointerdown', onPointer);
	document.addEventListener('keydown', onKey);
	return () => {
		document.removeEventListener('pointerdown', onPointer);
		document.removeEventListener('keydown', onKey);
	};
}
