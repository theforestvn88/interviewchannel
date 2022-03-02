export default class Sync {
	constructor(id, user_id, subscription) {
		this.id = id;
		this.user_id = user_id;
		this.subscription = subscription;
	}

  sync(component, data) {
    this.subscription.send({
      id: this.id,
      user_id: this.user_id,
      component: component,
      ...data
    });
  }
	
	// TODO: throtle
}
