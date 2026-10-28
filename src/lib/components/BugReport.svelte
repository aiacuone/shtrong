<script lang="ts">
	import { afterNavigate } from '$app/navigation';
	import { sendBugReport } from '$lib/bug-report';
	import Sheet from '$lib/components/Sheet.svelte';
	import { toast } from '$lib/toast.svelte';

	let open = $state(false);
	let form = $state<HTMLFormElement>();
	let kind = $state<'bug' | 'feature'>('bug');
	let title = $state('');
	let description = $state('');
	let page = $state('');
	let sending = $state(false);
	const feature = $derived(kind === 'feature');

	// Settings is where the button lives, so the page worth reporting is the one before it.
	afterNavigate(({ from }) => {
		if (from && from.url.pathname !== '/settings') page = from.url.pathname + from.url.search;
	});

	async function submit(event: SubmitEvent) {
		event.preventDefault();
		if (!form) return;
		sending = true;
		try {
			const url = await sendBugReport(form);
			title = description = page = '';
			open = false;
			toast(`${feature ? 'Feature request' : 'Bug'} filed as issue #${url.split('/').pop()}.`);
			kind = 'bug';
		} catch (err) {
			toast(err instanceof Error ? err.message : 'The report was not sent.', 'error');
		} finally {
			sending = false;
		}
	}
</script>

<div class="card stack">
	<h2>Bugs and features</h2>
	<p class="muted help">Report a bug or ask for a feature. Only you can see this. It opens an issue in your private bugs repo on GitHub.</p>
	<button type="button" class="btn" onclick={() => (open = true)}>Report or request</button>
</div>

<Sheet bind:open title={feature ? 'Request a feature' : 'Report a bug'}>
	<form id="bug-report-form" class="stack" bind:this={form} onsubmit={submit}>
		<fieldset>
			<legend>Type</legend>
			<div class="seg">
				<label><input type="radio" name="kind" value="bug" bind:group={kind} /><span>Bug</span></label>
				<label><input type="radio" name="kind" value="feature" bind:group={kind} /><span>Feature</span></label>
			</div>
		</fieldset>
		<label class="field">
			Title
			<input name="title" maxlength="120" required data-autofocus bind:value={title} />
		</label>
		<label class="field">
			{feature ? 'What should it do' : 'What happened'}
			<textarea name="description" rows="4" bind:value={description}></textarea>
		</label>
		<label class="field">
			Page
			<input name="page" bind:value={page} />
		</label>
		<label class="field">
			Screenshot (optional)
			<input name="screenshot" type="file" accept="image/*" />
		</label>
	</form>
	{#snippet footer()}
		<button class="btn primary" type="submit" form="bug-report-form" disabled={sending}>
			{sending ? 'Sending…' : feature ? 'Send request' : 'Send report'}
		</button>
	{/snippet}
</Sheet>
