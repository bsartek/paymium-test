require 'json'
require 'pry'
data = JSON.parse(File.open('data.json').read)

queue = data['queued_orders'].dup
while (order = queue.pop)
  data['queued_orders'].each do |match|
    next if match['direction'] == order['direction'] ||
            match['price'] != order['price']
    [order, match].each do |o|
      user = data['users'].detect { |user1| user1['id'] == o['user_id'] }
      if o['direction'] == 'sell'
        user['btc_balance'] -= o['btc_amount']
        user['eur_balance'] += o['btc_amount'] * o['price']
      else
        user['btc_balance'] += o['btc_amount']
        user['eur_balance'] -= o['btc_amount'] * o['price']
      end
      (data['orders'] ||= []).push(o.merge(state: 'executed'))
    end
    data['queued_orders'].delete(match)
    data['queued_orders'].delete(order)
  end
end

output_file = File.open('output.json', 'w')
output_file.write(data)
