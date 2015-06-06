
App = Em.Application.create({
    LOG_TRANSITIONS: true
});

App.Router.map(function() {
    this.resource('auth', { path: '/login' });
    this.resource('test', { path: '/test' });
    this.resource('hospitals', { path: '/hospitals/:criteria_id' });
});


/*
 * Routes
 */
App.HospitalsRoute = Em.Route.extend({
    model: function(params) {
        var route = this;

        Em.Logger.info("paramas: ", params);
        return App.Hospital.fetch({'rating_criteria': params.criteria_id, 'county': 'Fresno'});
    }

    //afterModel: function() {
    //    var route = this;
    //    route.transitionTo('stores');
    //},
});


/*
 * Controllers
 */


/*
 *
 * Helper Methods
 *
 */
App.reopen({
    apiBaseUri: 'api',
});


/*
 *
 * Models
 *
 */
var attr = Em.attr, hasMany = Em.hasMany;

App.Hospital = Em.Model.extend({
    id: attr(),
    name: attr()
});
App.Hospital.url = App.apiBaseUri + '/hospitals';
App.Hospital.camelizeKeys = true;
App.Hospital.adapter = Em.RESTAdapter.create();


