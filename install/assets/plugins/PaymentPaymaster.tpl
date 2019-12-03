//<?php
/**
 * Payment Paymaster
 *
 * Paymaster payments processing
 *
 * @category    plugin
 * @version     0.1.5
 * @author      mnoskov
 * @internal    @events OnRegisterPayments,OnBeforeOrderSending,OnManagerBeforeOrderRender
 * @internal    @properties &title=Название;text; &shop_id=Идентификатор магазина (shop_id);text;  &secret=Секретный ключ;text; &vat_code=Ставка НДС;list;НДС не облагается==no_vat||НДС 0%==vat0||НДС по формуле 10/110==vat110||НДС по формуле 18/118==vat118||НДС 10%==vat10||НДС 18%==vat18;no_vat &debug=Отладка;list;Нет==0||Да==1;0 &debug_mode=Режим тестирования;list;Все платежи успешные==0||Все платежи ошибочные==1||80% - успешные, 20% - ошибочные==2;0
 * @internal    @modx_category Commerce
 * @internal    @installset base
*/

if (empty($modx->commerce) && !defined('COMMERCE_INITIALIZED')) {
    return;
}

$commerce = ci()->commerce;
$lang = $commerce->getUserLanguage('paymaster');
$isSelectedPayment = !empty($order['fields']['payment_method']) && $order['fields']['payment_method'] == 'paymaster';

switch ($modx->event->name) {
    case 'OnRegisterPayments': {
        $class = new \Commerce\Payments\PaymasterPayment($modx, $params);

        if (empty($params['title'])) {
            $params['title'] = $lang['paymaster.caption'];
        }

        $commerce->registerPayment('paymaster', $params['title'], $class);
        break;
    }

    case 'OnBeforeOrderSending': {
        if ($isSelectedPayment) {
            $FL->setPlaceholder('extra', $FL->getPlaceholder('extra', '') . $commerce->loadProcessor()->populateOrderPaymentLink());
        }

        break;
    }

    case 'OnManagerBeforeOrderRender': {
        if (isset($params['groups']['payment_delivery']) && $isSelectedPayment) {
            $params['groups']['payment_delivery']['fields']['payment_link'] = [
                'title'   => $lang['paymaster.link_caption'],
                'content' => function($data) use ($modx, $commerce) {
                    return $commerce->loadProcessor()->populateOrderPaymentLink('@CODE:<a href="[+link+]" target="_blank">[+link+]</a>');
                },
                'sort' => 50,
            ];
        }

        break;
    }
}
