<script lang="ts">
	import { afterNavigate } from '$app/navigation';

	let { children } = $props();

	// Counts go to the portfolio's GoatCounter, prefixed with /strongr to keep them apart from its pages.
	const STATS = 'https://stats.portfolio-aiacuone.duckdns.org';
	let counter: Promise<void> | undefined;

	function loadCounter() {
		if (window.goatcounter?.count) return Promise.resolve();
		return (counter ??= new Promise((resolve) => {
			window.goatcounter = { no_onload: true };
			const script = document.createElement('script');
			script.async = true;
			script.dataset.goatcounter = `${STATS}/count`;
			script.src = `${STATS}/count.js`;
			script.onload = () => resolve();
			document.head.appendChild(script);
		}));
	}

	afterNavigate(({ to }) => {
		if (!to) return;
		const path = `/strongr${to.url.pathname}`;
		loadCounter().then(() => window.goatcounter?.count?.({ path }));
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
