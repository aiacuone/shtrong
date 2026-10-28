<script lang="ts">
	import { afterNavigate } from '$app/navigation';

	let { children } = $props();

	// Counts go to the portfolio's Umami site, prefixed with /shtrong to keep them apart from its pages.
	const UMAMI = 'https://stats-aiacuone.duckdns.org';
	const UMAMI_ID = '86eb39c6-0512-4268-9fe4-9711f48123b0';
	let umamiCounter: Promise<void> | undefined;

	function loadUmami() {
		if (window.umami) return Promise.resolve();
		return (umamiCounter ??= new Promise((resolve) => {
			const script = document.createElement('script');
			script.defer = true;
			script.dataset.websiteId = UMAMI_ID;
			script.dataset.autoTrack = 'false';
			script.src = `${UMAMI}/script.js`;
			script.onload = () => resolve();
			document.head.appendChild(script);
		}));
	}

	afterNavigate(({ to }) => {
		if (!to) return;
		const path = `/shtrong${to.url.pathname}`;
		if (location.hostname === 'localhost') return;
		loadUmami().then(() => window.umami?.track((props) => ({ ...props, url: path })));
	});
</script>

<div class="preview-banner">
	<span><strong>Interactive preview.</strong> This is a demonstration using sample data; anything you enter resets on refresh.</span>
</div>

{@render children()}

<style>
	.preview-banner {
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 0.75rem 1.25rem;
		padding: 0.55rem 1rem;
		border-bottom: 1px solid var(--line);
		background: var(--paper-2);
		color: var(--ink-2);
		font-size: 0.82rem;
		text-align: center;
	}
	@media (max-width: 560px) {
		.preview-banner {
			align-items: flex-start;
			flex-direction: column;
			gap: 0.15rem;
		}
	}
</style>
