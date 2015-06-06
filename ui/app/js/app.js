
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
//App.ApplicationRoute = Em.Route.extend({
//    setupController: function(controller, model) {
//        controller.set('fullHeader', true);
//    }
//});

App.HospitalsRoute = Em.Route.extend({
    model: function(params) {
        return App.Hospital.fetch({'rating_criteria': params.criteria_id, 'county': 'Fresno'});
    },

    //setupController: function(controller, model) {
    //    var route = this;
    //    controller.set('model', model);
    //}

    //afterModel: function() {
    //    var route = this;
    //    route.transitionTo('stores');
    //},
});


/*
 * Controllers
 */
App.ApplicationController = Ember.ObjectController.extend({
    fullHeader: true,

    init: function() {
        var controller = this;
        controller._super();
    },

    currentPathChanged: function() {
        var controller = this;

        Em.Logger.info("ApplicationController current path: " + this.get('currentPath'));

        if(controller.get('currentPath') == 'index') {
            controller.set('fullHeader', true);
        }

        if(controller.get('currentPath') != 'index') {
            controller.set('fullHeader', false);
        }
    }.observes('currentPath')
});

App.HospitalsController = Em.ObjectController.extend({
    needs: ['application'],

    init: function() {
        var controller = this;
        Em.Logger.info("in hosp controller");
        var appController = controller.get('controllers.application');
        appController.set('fullHeader', false);
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


