
# 📋 Task Management System API

A powerful and flexible task management system built with Ruby on Rails. It supports team-based task tracking with role-based access (Admin/Member), secure JWT authentication, background job processing using Sidekiq and Redis, and email notifications.

---

## 🚀 Features

- 🔒 **JWT Authentication** (login, logout, token management)
- 👥 **Team-based User Management** (Admin and Member roles)
- ✅ **Task Management** (create, assign, update, filter, paginate)
- 📨 **Email Notifications** for task assignments and updates
- ⏳ **Background Jobs** with Sidekiq & Redis
- 📚 **API Documentation** (Postman + PDF generation planned)

---

## 🛠️ Tech Stack

- **Backend**: Ruby on Rails 7
- **Auth**: JWT (`json_web_token.rb`)
- **Background Jobs**: Sidekiq + Redis
- **Database**: PostgreSQL
---

## 📂 Project Structure

```
app/
  controllers/
  models/
  serializers/
  jobs/
  mailers/
  abilities/
  services/
config/
  routes.rb
  sidekiq.yml
lib/
spec/
```

---

## 🔐 Authentication

This app uses **custom JWT-based authentication**.

### 🔑 Login

```http
POST /auth/login
```
**Body:**
```json
{
  "email": "user@example.com",
  "password": "password"
}
```

Returns an access token to be sent in headers for authorized requests:

```
Authorization: Bearer <your_token_here>
```

---

## 🧑‍🤝‍🧑 Roles & Permissions

- **Admin**: Can manage all tasks in their teams, assign tasks, invite members.
- **Member**: Can view and update only their assigned tasks.

Permissions managed using **CanCanCan** (`ability.rb`).

---

📦 API Endpoints
Authentication

Method	Endpoint	Description
POST	/signup	Register a new user
POST	/login	Login and get JWT
User Profile

Method	Endpoint	Description
GET	/users/profile	Get the current user's profile
Teams

Method	Endpoint	Description
POST	/teams/:team_id/invite	Invite a new member to the team
GET	/teams/:team_id/members	Get the members of a team
GET	/teams/:team_id/inviteable_users	Get the users who can be invited to the team
GET	/teams	List all teams
POST	/teams	Create a new team
Tasks

Method	Endpoint	Description
GET	/tasks	Admin: View all tasks, Member: View assigned tasks
GET	/tasks/:id	Show details of a task
POST	/teams/:team_id/tasks	Create a new task under the specified team
PATCH	/tasks/:id	Update task (status, priority)
DELETE	/tasks/:id	Delete a task by ID
PATCH	/tasks/:id/assign	Assign a task to a user

Supports filtering via query params:  
`/tasks?status=pending&priority=high&page=1`

---

## ⏳ Background Jobs

- Powered by **Sidekiq** + **Redis**
- Used for async email notifications, team invites, etc.

Start Redis & Sidekiq:

```bash
redis-server
bundle exec sidekiq
```

Access Sidekiq UI at: `http://localhost:3000/sidekiq`

---


Access API at: `http://localhost:3000`

---


## 📥 API Documentation

Planned:

- ✅ Postman Collection
- ✅ PDF Documentation of API (via Rswag)
---

## 📄 License

MIT License. Feel free to use and contribute!

---

## 👨‍💻 Author

**Atul**  
🔗 [github.com/atul13055](https://github.com/atul13055)