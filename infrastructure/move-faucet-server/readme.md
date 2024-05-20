### Implementing the Move Faucet

> The faucet access frequency can be rate-limited based on the IP address, and the faucet amount can be configured.

### Usage

1. Clone this repository.

2. Install the dependencies:
   ```bash
   npm install
   ```

3. Set up the environment variables:
   ```bash
   cp .env.example .env
   ```

4. Start the server:
   ```bash
   node src/app.js
   ```