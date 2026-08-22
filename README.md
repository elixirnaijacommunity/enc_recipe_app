ENC Recipes

ENC Recipes is a community-driven recipe and food-focused social application built as an Elixir project within the Elixir Nigeria Community (ENC).

Problem Statement

ENC is a community made up of people from different backgrounds and interests who communicate and collaborate for various purposes. However, there is no dedicated platform focused specifically on food, recipes, food culture, and connecting people within the food ecosystem.

This creates an opportunity to build a focused community where people can share their recipes, discover different food cultures, connect with others who share similar interests, and collaborate around food.

Solution

ENC Recipes aims to address this problem by providing a dedicated social platform for the food ecosystem.

The application allows users to:

Create and manage recipes
Share recipes with the community
Discover recipes and different food cultures
Connect and interact with people who share similar interests
Build a community around food and cooking

The project is designed to combine recipe management with social interaction, creating a space where food enthusiasts, creators, and other members of the community can connect and learn from one another.

Architecture

ENC Recipes follows a Modular Monolith architecture and applies principles of Domain-Driven Design (DDD).

The application is organized around business domains, with each domain responsible for a specific area of the application's functionality. This approach helps keep the codebase maintainable, encourages clear separation of responsibilities, and makes the system easier to evolve as new features are introduced.

Technology Stack
Frontend
Hologram — UI development and frontend implementation
Backend
Phoenix — Web application framework
Elixir — Primary backend programming language
Ecto — Database interaction and data persistence
Database
PostgreSQL — Relational database

PostgreSQL is used because the application requires relational data modeling, constraints, transactions, and interactions between multiple entities.

Getting Started
Prerequisites

Before setting up the project, make sure you have:

Git installed
asdf installed
Access to the project repository
Installation

1. Fork the repository

Fork the repository to your GitHub account.

2. Clone your fork

Clone the forked repository to your local machine:

git clone <your-fork-url></your>
cd <project-directory></project> 3. Install project dependencies

The project uses .tool-versions to define the required versions of Elixir, Erlang, and Node.js.

Run:

asdf install 4. Set up the application

Run:

mix setup

This command installs the required dependencies and prepares the application for development.

5. Start the application

To start the Hologram frontend, run:

mix holo

For additional development commands, see the project documentation in:

docs/
Project Documentation

Additional documentation about the project architecture, development workflow, commands, and contributing can be found in the docs/ directory.

Learn More

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix
- Hologram: https://hologram.page/docs/introduction
  Community

ENC Recipes is an Elixir Nigeria Community project built to encourage collaboration, learning, and experimentation within the Elixir ecosystem.
# enc_recipe_app
