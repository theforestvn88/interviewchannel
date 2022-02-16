export default class Sync {
	constructor(id, user, subscription) {
		this.id = id;
		this.user = user;
		this.subscription = subscription;
	}

  sync(component, data) {
    this.subscription.send({
      id: this.id,
      user: this.user,
      component: component,
      ...data
    });
  }
	
	// TODO: throtle
}
