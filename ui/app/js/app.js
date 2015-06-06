
App = Em.Application.create({
    LOG_TRANSITIONS: true
});

App.Router.map(function() {
    this.resource('auth', { path: '/login' });
    this.resource('test', { path: '/test' });
});


/*
 * Controllers
 */
App.AuthController = Em.ObjectController.extend({
    loginError: false,

    // Values from the login form
    email: null,
    password: null,

    login: function(controller, formUsername, formPassword) {

        return new Em.RSVP.Promise(function(resolve, reject) {
            var uri = '%@/authenticate'.fmt(App.apiBaseUri);
            var sendData = {};
            sendData['email'] = formUsername;
            sendData['password'] = formPassword;
            console.log(sendData);

            Em.$.ajax({
                type: "POST",
                url: uri,
                data: JSON.stringify(sendData),
                contentType: 'application/json',
                complete: function(xhr) {
                    if(/2../.exec(xhr.status)) {
                        if(! Em.isNone(controller.get('loginError'))) {
                            controller.set('loginError', false);
                        }

                        //var user = Em.$.parseJSON(xhr.responseText)['data'];
                        //controller._displayAuthenticatedUser(user);

                        controller.transitionToRoute('test');
                    } else {
                        if(! Em.isNone(controller.get('loginError'))) {
                            controller.set('loginError', true);
                        }
                    }
                }
            });
        });
    },

    logout: function() {
        var controller = this;

        return new Em.RSVP.Promise(function(resolve, reject) {
            var uri = '%@/logout'.fmt(App.apiBaseUri);
            Em.$.ajax({
                type: "POST",
                url: uri,
                complete: function(xhr) {
                    if(/2../.exec(xhr.status)) {
                        resolve();
                    } else {
                        reject();
                    }
                }
            });
        });
    },

    actions: {
        submitLogin: function() {
            var controller = this;
            var formUsername = controller.get('email');
            var formPassword = controller.get('password');
            return controller.login(this, formUsername, formPassword);
        }
    }
});



/*
 *
 * Helper Methods
 *
 */
App.reopen({
    apiBaseUri: 'api',
});


