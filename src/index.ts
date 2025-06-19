import { Container, getContainer, loadBalance } from '@cloudflare/containers';

export class Webtop extends Container {
	defaultPort = 3000;
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
		const { hostname, pathname } = new URL(request.url);
		const isLocal = hostname === 'localhost' ? true : false;

		// if (isLocal) {
		// 	return await fetch('http://localhost:8080' + pathname, request);
		// }

		// let container = await loadBalance(env.WEBTOP, 3);
		// return await container.fetch(request);

		return await getContainer(env.WEBTOP).fetch(request);
	},
} satisfies ExportedHandler<Env>;
