//<?php
/**
 * Payment Paymaster
 *
 * Paymaster payments processing
 *
 * @category    plugin
 * @version     0.1.3
 * @author      mnoskov
 * @internal    @events OnRegisterPayments,OnBeforeOrderSending
 * @internal    @properties &title=Название;text; &shop_id=Идентификатор магазина (shop_id);text;  &secret=Секретный ключ;text; &vat_code=Ставка НДС;list;НДС не облагается==no_vat||НДС 0%==vat0||НДС по формуле 10/110==vat110||НДС по формуле 18/118==vat118||НДС 10%==vat10||НДС 18%==vat18;no_vat &debug=Отладка;list;Нет==0||Да==1;0 &debug_mode=Режим тестирования;list;Все платежи успешные==0||Все платежи ошибочные==1||80% - успешные, 20% - ошибочные==2;0
 * @internal    @modx_category Commerce
 * @internal    @installset base
*/

if (empty($modx->commerce) && !defined('COMMERCE_INITIALIZED')) {
    return;
}

switch ($modx->event->name) {
    case 'OnRegisterPayments': {
        $class = new \Commerce\Payments\PaymasterPayment($modx, $params);

        if (empty($params['title'])) {
            $lang = $modx->commerce->getUserLanguage('paymaster');
            $params['title'] = $lang['paymaster.caption'];
        }

        $modx->commerce->registerPayment('paymaster', $params['title'], $class);
        break;
    }

    case 'OnBeforeOrderSending': {
        if (!empty($order['fields']['payment_method']) && $order['fields']['payment_method'] == 'paymaster') {
            $FL->setPlaceholder('extra', $FL->getPlaceholder('extra', '') . $modx->commerce->loadProcessor()->populateOrderPaymentLink());
        }

        break;
    }
}
