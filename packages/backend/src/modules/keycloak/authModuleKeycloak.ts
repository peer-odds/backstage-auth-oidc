import { createBackendModule } from '@backstage/backend-plugin-api';
import {
  authProvidersExtensionPoint,
  createOAuthProviderFactory,
} from '@backstage/plugin-auth-node';
import { oidcAuthenticator } from '@backstage/plugin-auth-backend-module-oidc-provider';
import { stringifyEntityRef, DEFAULT_NAMESPACE } from '@backstage/catalog-model'; // Added import for stringifyEntityRef and DEFAULT_NAMESPACE

const KeycloakAuthModule = createBackendModule({
  // This ID must match the "auth" plugin which this module targets
  pluginId: 'auth',
  // Unique module ID, can be customized
  moduleId: 'keycloak-provider',
  register(reg) {
    reg.registerInit({
      deps: { providers: authProvidersExtensionPoint },
      async init({ providers }) {
        providers.registerProvider({
          // Ensure this matches your configuration in app-config.yaml
          providerId: 'keycloak-provider',
          // Create an OAuth-based factory with the OIDC authenticator
          factory: createOAuthProviderFactory({
            authenticator: oidcAuthenticator,
            
            async signInResolver(info, ctx) {
              // Resolve user identity and create a token
              const userRef = stringifyEntityRef({
                kind: 'User',
                name: info.result.fullProfile.userinfo.sub,
                namespace: DEFAULT_NAMESPACE,
              });
              return ctx.issueToken({
                claims: {
                  sub: userRef, // User's unique identity
                  ent: [userRef], // List of user-owned identities
                },
              });
            },
          }),
        });
      },
    });
  },
});

export default KeycloakAuthModule;
