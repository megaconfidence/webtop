import { Container, getContainer, loadBalance } from '@cloudflare/containers';

export class Webtop extends Container {
	defaultPort = 6901;
	sleepAfter = '15m';
	override onStart() {
		console.log('Container successfully started');
	}

	override onStop() {
		console.log('Container successfully shut down');
	}

	override onError(error: unknown) {
		console.log('Container error:', error);
	}
}

export default {
	async fetch(request: Request, env): Promise<Response> {
		// return await getContainer(env.WEBTOP).fetch(request);
		let container = await loadBalance(env.WEBTOP, 10);
		return await container.fetch(request);
	},
} satisfies ExportedHandler<Env>;
