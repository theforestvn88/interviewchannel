export default class Sync {
	constructor(id, user_id, user_name, subscription) {
		this.id = id;
		this.user_id = user_id;
		this.user_name = user_name;
		this.subscription = subscription;
	}

  sync(component, data) {
    this.subscription.send({
      id: this.id,
      user_id: this.user_id,
      user_name: this.user_name,
      component: component,
      ...data
    });
  }
	
	// TODO: throtle
}
