{
  "plugin": {
    "id": "coins-ph-plugin",
    "name": "Coins.ph Superalgos Plugin",
    "version": "1.0.0",
    "exchanges": ["coins-ph"]
  }
}
javascript title="exchanges/coins-ph.js"
const crypto   = require('crypto');
const fetch    = require('node-fetch');

const API_BASE = 'https://api.coins.ph/v3';

function getHeaders(path, method, body = {}, apiKey, apiSecret) {
  const timestamp = Math.floor(Date.now() / 1000).toString();
  const payload   = apiKey + timestamp + method + path + (method === 'GET' ? '' : JSON.stringify(body));
  const signature = crypto.createHmac('sha256', apiSecret)
                          .update(payload)
                          .digest('hex');

  return {
    'X-COINS-APIKEY':    apiKey,
    'X-COINS-TIMESTAMP': timestamp,
    'X-COINS-SIGNATURE': signature,
    'Content-Type':      'application/json'
  };
}

async function apiRequest(path, method, body, config) {
  const url     = API_BASE + path;
  const headers = getHeaders(path, method, body, config.apiKey, config.apiSecret);
  const opts    = { method, headers };
  if (method !== 'GET') opts.body = JSON.stringify(body);

  const res = await fetch(url, opts);
  const j   = await res.json();
  if (!j.success) throw new Error(`Coins.ph error: ${JSON.stringify(j)}`);
  return j.data;
}

module.exports = {
  name: 'coins-ph',

  // 1. Fetch available trading pairs
  async getMarkets(config) {
    const markets = await apiRequest('/market/list', 'GET', {}, config);
    return markets.map(m => ({
      symbol: `${m.base_currency}-${m.quote_currency}`,
      base:   m.base_currency,
      quote:  m.quote_currency,
      lot:    parseFloat(m.min_trade_amount)
    }));
  },

  // 2. Fetch latest ticker for a single symbol
  async getTicker(symbol, config) {
    const [base, quote] = symbol.split('-');
    const data = await apiRequest(
      `/market/ticker/${base}-${quote}`, 'GET', {}, config
    );
    return {
      symbol,
      bid:  parseFloat(data.best_bid),
      ask:  parseFloat(data.best_ask),
      last: parseFloat(data.last)
    };
  },

  // 3. Fetch account balances
  async getBalance(config) {
    const balances = await apiRequest('/account/balance', 'GET', {}, config);
    return balances.map(b => ({
      currency: b.asset,
      free:     parseFloat(b.available),
      used:     parseFloat(b.locked)
    }));
  },

  // 4. Place a new order
  async placeOrder(symbol, type, side, amount, price, config) {
    const [base, quote] = symbol.split('-');
    const body = {
      base_currency:  base,
      quote_currency: quote,
      type,    // "limit" or "market"
      side,    // "buy" or "sell"
      amount:  amount.toString(),
      price:   price?.toString()    // omit for market orders
    };
    const order = await apiRequest('/orders', 'POST', body, config);
    return {
      id:       order.id,
      symbol,
      side:     order.side,
      type:     order.type,
      price:    parseFloat(order.price),
      amount:   parseFloat(order.amount),
      filled:   parseFloat(order.filled),
      timestamp: new Date(order.timestamp * 1000)
    };
  },

  // 5. Cancel an order by ID
  async cancelOrder(orderId, symbol, config) {
    const path = `/orders/${orderId}`;
    await apiRequest(path, 'DELETE', {}, config);
    return { id: orderId };
  },

  // 6. Get open orders (optionally filtered by symbol)
  async getOpenOrders(symbol, config) {
    const path = symbol
      ? `/orders?symbol=${symbol}`
      : '/orders';
    const orders = await apiRequest(path, 'GET', {}, config);
    return orders.map(o => ({
      id:        o.id,
      symbol:    `${o.base_currency}-${o.quote_currency}`,
      side:      o.side,
      type:      o.type,
      price:     parseFloat(o.price),
      amount:    parseFloat(o.amount),
      filled:    parseFloat(o.filled),
      timestamp: new Date(o.timestamp * 1000)
    }));
  },

  // 7. Fetch trade history (fills) for a symbol
  async getTrades(symbol, config) {
    const [base, quote] = symbol.split('-');
    const trades = await apiRequest(
      `/orders/trades?base_currency=${base}&quote_currency=${quote}`, 
      'GET', {}, 
      config
    );
    return trades.map(t => ({
      id:        t.trade_id,
      orderId:   t.order_id,
      symbol,
      side:      t.side,
      price:     parseFloat(t.price),
      amount:    parseFloat(t.amount),
      timestamp: new Date(t.timestamp * 1000)
    }));
  }
};
