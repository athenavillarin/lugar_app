// Notification model placeholder
class NotificationModel {
  constructor(id, title, body, createdAt = new Date()) {
    this.id = id;
    this.title = title;
    this.body = body;
    this.createdAt = createdAt;
  }
}

module.exports = NotificationModel;
