#!/usr/bin/env bash

#color attr lemon/poly
B_RED=%{B#cc444b}
B_GREEN=%{B#499f68}
F_RED=%{F#cc444b}
F_GREEN=%{F#499f68}

#btc to usd 
btc() {
    btc_usd=$(curl -sf https://api.coinmarketcap.com/v2/ticker/1/ | jq -r '.data.quotes.USD.price')    
    btc_percent_change_24h=$(curl -sf https://api.coinmarketcap.com/v2/ticker/1/ | jq -r '.data.quotes.USD.percent_change_24h')

    if [[ $btc_percent_change_24h = *'-'*  ]] ; then
	echo "$B_RED BTC %{B-} $btc_usd $F_RED▼ $btc_percent_change_24h%{F-} "
    else
	echo "$B_GREEN BTC %{B-} $btc_usd $F_GREEN▲ $btc_percent_change_24h%{F-} "
    fi
}

#shitcoins
declare -a symbol=(ETH XRP BCH LTC XLM NEO ZEC BTG DOGE)

#shitcoin to btc
shitcoin() {
    for (( i=0; i<${#symbol[@]}; i++ )) ; do
	price[$i]=$(curl -sf https://api.coinmarketcap.com/v2/ticker/?convert=BTC | jq -r --arg symbol "${symbol[$i]}" '.data[] | if .symbol == $symbol then .quotes.BTC.price else empty end')
	percent_change_24h[$i]=$(curl -sf https://api.coinmarketcap.com/v2/ticker/?convert=BTC | jq -r --arg symbol "${symbol[$i]}" '.data[] | if .symbol == $symbol then .quotes.BTC.percent_change_24h else empty end')

	price[$i]=$(LANG=C printf "%.8f" "${price[$i]}")
	
	if [[ ${percent_change_24h[$i]} = *'-'* ]] ; then
	    symbol[$i]="$B_RED ${symbol[$i]} %{B-} ${price[$i]} $F_RED▼ ${percent_change_24h[$i]}%{F-} "
	else
	    symbol[$i]="$B_GREEN ${symbol[$i]} %{B-} ${price[$i]} $F_GREEN▲ ${percent_change_24h[$i]}%{F-} "
	fi
    done
    echo ${symbol[@]}
}

if ping -q -c 1 1.1.1.1 >/dev/null ; then
    echo "$(btc)$(shitcoin)"
    unset symbol
else
    echo "NO NETWORK"
fi
