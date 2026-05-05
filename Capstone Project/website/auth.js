/**
 * ELLORE Cognito Authentication Library
 * 
 * This file handles all Amazon Cognito authentication operations
 * including signup, login, logout, and session management.
 */

// ═══════════════════════════════════════════════════════════════
// COGNITO CONFIGURATION
// ═══════════════════════════════════════════════════════════════
// Update these values after running: terraform output

const COGNITO_CONFIG = {
    UserPoolId: 'eu-central-1_uJl0dqnGk',        // terraform output cognito_user_pool_id
    ClientId: '81on4s6ejvm9ibnivt8o4ab8g',             // terraform output cognito_client_id
    Region: 'eu-central-1'                  // terraform output cognito_region
};

// ═══════════════════════════════════════════════════════════════
// COGNITO AUTHENTICATION CLASS
// ═══════════════════════════════════════════════════════════════

class CognitoAuth {
    constructor(config) {
        this.config = config;
        this.cognitoEndpoint = `https://cognito-idp.${config.Region}.amazonaws.com/`;
    }

    /**
     * Make request to Cognito API
     */
    async makeRequest(action, body) {
        const headers = {
            'Content-Type': 'application/x-amz-json-1.1',
            'X-Amz-Target': `AWSCognitoIdentityProviderService.${action}`
        };

        const response = await fetch(this.cognitoEndpoint, {
            method: 'POST',
            headers: headers,
            body: JSON.stringify(body)
        });

        const data = await response.json();

        if (!response.ok) {
            throw {
                code: data.__type ? data.__type.split('#')[1] : 'UnknownError',
                message: data.message || 'An error occurred'
            };
        }

        return data;
    }

    /**
     * Sign up new user
     */
    async signUp(email, password, name) {
        try {
            const body = {
                ClientId: this.config.ClientId,
                Username: email,
                Password: password,
                UserAttributes: [
                    { Name: 'email', Value: email },
                    { Name: 'name', Value: name }
                ]
            };

            const response = await this.makeRequest('SignUp', body);

            return {
                success: true,
                userSub: response.UserSub,
                userConfirmed: response.UserConfirmed,
                message: 'Registration successful! Please check your email for verification code.'
            };

        } catch (error) {
            console.error('SignUp error:', error);
            throw error;
        }
    }

    /**
     * Confirm user email with verification code
     */
    async confirmSignUp(email, code) {
        try {
            const body = {
                ClientId: this.config.ClientId,
                Username: email,
                ConfirmationCode: code
            };

            await this.makeRequest('ConfirmSignUp', body);

            return {
                success: true,
                message: 'Email verified successfully! You can now login.'
            };

        } catch (error) {
            console.error('ConfirmSignUp error:', error);
            throw error;
        }
    }

    /**
     * Resend verification code
     */
    async resendConfirmationCode(email) {
        try {
            const body = {
                ClientId: this.config.ClientId,
                Username: email
            };

            await this.makeRequest('ResendConfirmationCode', body);

            return {
                success: true,
                message: 'Verification code resent! Check your email.'
            };

        } catch (error) {
            console.error('ResendConfirmationCode error:', error);
            throw error;
        }
    }

    /**
     * Sign in user
     */
    async signIn(email, password) {
        try {
            const body = {
                ClientId: this.config.ClientId,
                AuthFlow: 'USER_PASSWORD_AUTH',
                AuthParameters: {
                    USERNAME: email,
                    PASSWORD: password
                }
            };

            const response = await this.makeRequest('InitiateAuth', body);

            if (response.AuthenticationResult) {
                const tokens = response.AuthenticationResult;

                // Store tokens in localStorage
                localStorage.setItem('idToken', tokens.IdToken);
                localStorage.setItem('accessToken', tokens.AccessToken);
                localStorage.setItem('refreshToken', tokens.RefreshToken);

                // Decode and store user info
                const userInfo = this.parseJWT(tokens.IdToken);
                localStorage.setItem('userEmail', userInfo.email);
                localStorage.setItem('userName', userInfo.name || email);

                return {
                    success: true,
                    user: userInfo,
                    message: 'Login successful!'
                };
            }

        } catch (error) {
            console.error('SignIn error:', error);
            throw error;
        }
    }

    /**
     * Sign out user
     */
    signOut() {
        localStorage.removeItem('idToken');
        localStorage.removeItem('accessToken');
        localStorage.removeItem('refreshToken');
        localStorage.removeItem('userEmail');
        localStorage.removeItem('userName');

        return {
            success: true,
            message: 'Logged out successfully'
        };
    }

    /**
     * Get current session
     */
    async currentSession() {
        const idToken = localStorage.getItem('idToken');
        const accessToken = localStorage.getItem('accessToken');

        if (!idToken || !accessToken) {
            return null;
        }

        // Check if token is expired
        const tokenInfo = this.parseJWT(idToken);
        const currentTime = Math.floor(Date.now() / 1000);

        if (tokenInfo.exp < currentTime) {
            // Token expired, try to refresh
            return await this.refreshSession();
        }

        return {
            idToken: idToken,
            accessToken: accessToken,
            user: tokenInfo
        };
    }

    /**
     * Refresh session tokens
     */
    async refreshSession() {
        try {
            const refreshToken = localStorage.getItem('refreshToken');

            if (!refreshToken) {
                this.signOut();
                return null;
            }

            const body = {
                ClientId: this.config.ClientId,
                AuthFlow: 'REFRESH_TOKEN_AUTH',
                AuthParameters: {
                    REFRESH_TOKEN: refreshToken
                }
            };

            const response = await this.makeRequest('InitiateAuth', body);

            if (response.AuthenticationResult) {
                const tokens = response.AuthenticationResult;

                localStorage.setItem('idToken', tokens.IdToken);
                localStorage.setItem('accessToken', tokens.AccessToken);

                const userInfo = this.parseJWT(tokens.IdToken);

                return {
                    idToken: tokens.IdToken,
                    accessToken: tokens.AccessToken,
                    user: userInfo
                };
            }

        } catch (error) {
            console.error('RefreshSession error:', error);
            this.signOut();
            return null;
        }
    }

    /**
     * Change password
     */
    async changePassword(oldPassword, newPassword) {
        try {
            const accessToken = localStorage.getItem('accessToken');

            if (!accessToken) {
                throw { code: 'NotAuthorizedException', message: 'Not logged in' };
            }

            const body = {
                AccessToken: accessToken,
                PreviousPassword: oldPassword,
                ProposedPassword: newPassword
            };

            await this.makeRequest('ChangePassword', body);

            return {
                success: true,
                message: 'Password changed successfully!'
            };

        } catch (error) {
            console.error('ChangePassword error:', error);
            throw error;
        }
    }

    /**
     * Forgot password - initiate reset
     */
    async forgotPassword(email) {
        try {
            const body = {
                ClientId: this.config.ClientId,
                Username: email
            };

            await this.makeRequest('ForgotPassword', body);

            return {
                success: true,
                message: 'Password reset code sent to your email!'
            };

        } catch (error) {
            console.error('ForgotPassword error:', error);
            throw error;
        }
    }

    /**
     * Confirm forgot password with code
     */
    async confirmForgotPassword(email, code, newPassword) {
        try {
            const body = {
                ClientId: this.config.ClientId,
                Username: email,
                ConfirmationCode: code,
                Password: newPassword
            };

            await this.makeRequest('ConfirmForgotPassword', body);

            return {
                success: true,
                message: 'Password reset successful! You can now login.'
            };

        } catch (error) {
            console.error('ConfirmForgotPassword error:', error);
            throw error;
        }
    }

    /**
     * Get user attributes
     */
    async getUserAttributes() {
        try {
            const accessToken = localStorage.getItem('accessToken');

            if (!accessToken) {
                throw { code: 'NotAuthorizedException', message: 'Not logged in' };
            }

            const body = {
                AccessToken: accessToken
            };

            const response = await this.makeRequest('GetUser', body);

            return {
                username: response.Username,
                attributes: response.UserAttributes.reduce((acc, attr) => {
                    acc[attr.Name] = attr.Value;
                    return acc;
                }, {})
            };

        } catch (error) {
            console.error('GetUserAttributes error:', error);
            throw error;
        }
    }

    /**
     * Parse JWT token
     */
    parseJWT(token) {
        try {
            const base64Url = token.split('.')[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
            const jsonPayload = decodeURIComponent(atob(base64).split('').map(function (c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));

            return JSON.parse(jsonPayload);
        } catch (error) {
            console.error('JWT parse error:', error);
            return null;
        }
    }

    /**
     * Check if user is authenticated
     */
    async isAuthenticated() {
        const session = await this.currentSession();
        return session !== null;
    }

    /**
     * Get current user info
     */
    getCurrentUser() {
        return {
            email: localStorage.getItem('userEmail'),
            name: localStorage.getItem('userName')
        };
    }
}

// ═══════════════════════════════════════════════════════════════
// INITIALIZE AUTH
// ═══════════════════════════════════════════════════════════════

const Auth = new CognitoAuth(COGNITO_CONFIG);

// ═══════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════

/**
 * Require authentication - redirect to login if not authenticated
 */
async function requireAuth() {
    const isAuth = await Auth.isAuthenticated();
    if (!isAuth) {
        window.location.href = 'login.html';
        return false;
    }
    return true;
}

/**
 * Make authenticated API call
 */
async function makeAuthenticatedRequest(url, options = {}) {
    const session = await Auth.currentSession();

    if (!session) {
        throw new Error('Not authenticated');
    }

    const headers = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${session.idToken}`,
        ...options.headers
    };

    const response = await fetch(url, {
        ...options,
        headers
    });

    if (response.status === 401) {
        // Token expired or invalid, redirect to login
        Auth.signOut();
        window.location.href = 'login.html';
        throw new Error('Session expired');
    }

    return response;
}

/**
 * Display user info in header
 */
async function displayUserInfo() {
    const session = await Auth.currentSession();

    if (session) {
        const user = Auth.getCurrentUser();
        const userInfoElement = document.getElementById('user-info');

        if (userInfoElement) {
            userInfoElement.innerHTML = `
                <span>Welcome, ${user.name || user.email}</span>
                <a href="account.html">My Account</a>
                <a href="#" onclick="logout()">Logout</a>
            `;
        }
    }
}

/**
 * Logout function
 */
function logout() {
    Auth.signOut();
    window.location.href = 'index.html';
}

// ═══════════════════════════════════════════════════════════════
// AUTO-REFRESH TOKENS
// ═══════════════════════════════════════════════════════════════

// Refresh tokens every 30 minutes
setInterval(async () => {
    const session = await Auth.currentSession();
    if (session) {
        console.log('Token refreshed');
    }
}, 30 * 60 * 1000);
