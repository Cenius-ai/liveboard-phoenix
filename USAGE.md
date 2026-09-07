# Usage Guide

Once the server is running (`mix phx.server`), open `http://localhost:4000` in your browser.

## User Registration and Login

- **Sign Up** – Click the "Register" link on the home page and fill in your email and password.
- **Log In** – Use the credentials you created to access the application.
- After logging in, you are redirected to your dashboard.

The seeded demo account (if you ran `mix setup`) uses the credentials:
- Email: `demo@example.com`  
- Password: `password1234`

## Dashboard

The dashboard (`/` or `/dashboard`) lists all boards belonging to you. Click any board title to open its detail view.

## Board Detail

Inside a board, you will see three default columns: **To Do**, **Doing**, and **Done**.

- **Add a Column** – Use the "+ Add Column" button, type a name, and submit.
- **Add a Card** – Inside any column, click "+ Add Card", enter a title, and press Enter or click the add button.
- **Drag & Drop** – Grab a card and drag it to another column. The move is instantly reflected for all viewers of the board.
- **Edit/Delete** – Cards can be edited or deleted using the icons that appear on hover.

All changes (card creation, movement, deletion, column additions) are broadcast in real time using Phoenix LiveView. Open the same board in another browser window or incognito tab to see live updates.

## Settings

Click your username (or user icon) in the navigation bar and select "Settings" to:
- Update your email or password.
- Delete your account.

## Additional Notes

- The application uses SQLite for storage; data persists in the file specified by `DATABASE_PATH`.
- For a fresh start, you can delete the database file and re-run `mix setup`.
- Development server supports hot reloading of templates and LiveView modules without a full restart.