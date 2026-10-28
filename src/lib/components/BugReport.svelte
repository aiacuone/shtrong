<script lang="ts">
	import { afterNavigate } from '$app/navigation';
	import { sendBugReport } from '$lib/bug-report';
	import { toast } from '$lib/toast.svelte';

	let form = $state<HTMLFormElement>();
	let page = $state('');
	let sending = $state(false);

	// Settings is where the form lives, so the page worth reporting is the one before it.
	afterNavigate(({ from }) => {
		if (from && from.url.pathname !== '/settings') page = from.url.pathname + from.url.search;
	});

	async function submit(event: SubmitEvent) {
		event.preventDefault();
		if (!form) return;
		sending = true;
		try {
			const url = await sendBugReport(form);
			form.reset();
			page = '';
			toast(`Bug reported as issue #${url.split('/').pop()}.`);
		} catch (err) {
			toast(err instanceof Error ? err.message : 'The bug report was not sent.', 'error');
		} finally {
			sending = false;
		}
	}
</script>

<form class="card stack" bind:this={form} onsubmit={submit}>
	<h2>Report a bug</h2>
	<p class="muted help">Only you can see this. It opens an issue in your private bugs repo on GitHub.</p>
	<label class="field">
		Title
		<input name="title" maxlength="120" required />
	</label>
	<label class="field">
		What happened
		<textarea name="description" rows="4"></textarea>
	</label>
	<label class="field">
		Page
		<input name="page" bind:value={page} />
	</label>
	<label class="field">
		Screenshot (optional)
		<input name="screenshot" type="file" accept="image/*" />
	</label>
	<button class="btn primary" disabled={sending}>{sending ? 'Sending…' : 'Send report'}</button>
</form>
