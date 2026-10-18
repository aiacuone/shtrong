/// <reference types="vite-plugin-pwa/info" />
/// <reference types="vite-plugin-pwa/svelte" />
/// <reference types="vite-plugin-pwa/client" />

declare global {
	namespace App {
		interface Locals {
			user: { id: string; username: string; email: string } | null;
		}
	}

	interface Window {
		goatcounter?: { no_onload?: boolean; count?: (vars: { path: string }) => void };
	}
}

export {};
