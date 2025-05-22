import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joo_express/models/product.dart';
import 'package:joo_express/screens/cart/cart_page.dart';
import 'package:joo_express/widgets/neumorphic_widgets.dart';

class SheinScreen extends StatefulWidget {
  const SheinScreen({Key? key}) : super(key: key);

  @override
  _SheinScreenState createState() => _SheinScreenState();
}

class _SheinScreenState extends State<SheinScreen> {
  late InAppWebViewController webViewController;
  bool _canGoBack = false;
  bool _canGoForward = false;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = prefs.getStringList('cart') ?? [];
    if (mounted) {
      setState(() {
        _cartItemCount = cartList.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      appBar: AppBar(
        title: Text('متصفح SHEIN'),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.link),
                tooltip: 'بحث بالرابط',
                onPressed: () {
                  _showSearchByLinkDialog(context);
                },
              );
            }
          ),
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.share),
                tooltip: 'مشاركة الصفحة',
                onPressed: () {
                  _shareCurrentPage();
                },
              );
            }
          ),
          Builder(
            builder: (BuildContext iconButtonContext) {
              return badges.Badge(
                position: badges.BadgePosition.topEnd(top: 0, end: 3),
                badgeContent: Text(
                  _cartItemCount.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                showBadge: _cartItemCount > 0,
                child: IconButton(
                  icon: Icon(Icons.shopping_cart_outlined),
                  onPressed: () async {
                    await Navigator.push(
                      iconButtonContext,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    );
                    if (mounted) {
                      _loadCartCount();
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
        body: InAppWebView(
    initialUrlRequest: URLRequest(url: WebUri('https://m.shein.com/')),
    initialSettings: InAppWebViewSettings(
      javaScriptEnabled: true,
      domStorageEnabled: true,
      useShouldInterceptRequest: true,
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
    ),
    onWebViewCreated: (controller) {
      webViewController = controller;
      controller.addJavaScriptHandler(
        handlerName: 'addToCartHandler',
        callback: _handleAddToCart,
      );
    },
    onLoadStop: (controller, url) async {
      // تحديث حالة أزرار الرجوع والتقدم
      if (mounted) {
        final cgb = await controller.canGoBack();
        final cgf = await controller.canGoForward();
        setState(() {
          _canGoBack = cgb;
          _canGoForward = cgf;
        });
      }
      
      // حقن كود JavaScript مع تأخير بسيط للتأكد من تحميل الصفحة بالكامل
      await Future.delayed(Duration(milliseconds: 500));

          // حقن كود JavaScript
          String jsCode = r"""
            (function() {
              console.log('SHEIN Custom Script: Initializing - v2.2'); // Versioning for easier debugging

              // --- CSS Injection for Hiding SHEIN's UI elements ---
              const styleId = 'sheinCustomHideStyle';
              if (!document.getElementById(styleId)) {
                const style = document.createElement('style');
                style.id = styleId;
                style.innerHTML = `
                  /* ... (CSS الموجود لإخفاء عناصر SHEIN يبقى كما هو) ... */
                  /* Common SHEIN footer/bottom navigation selectors - adjust as needed */
                  .footer-container, .footer, .bottom-nav, .sui-bottom-nav,
                  .she-bottom-bar, .common-footer, #footer, [class*="footer"], [id*="footer"],
                  .detail-bottom-fixedtool-container, /* Example for product page bottom bar */
                  .she-common-navigation-bar, /* Another common nav bar */
                  .layout-bottom-nav-new, /* SHEIN mobile bottom nav */
                  .SProductDetailBottomToolLayout, /* Product detail bottom tool */
                  .she-float-entry, /* Floating entries like app download prompts */
                  .float-layer-container, /* Generic float layer container */
                  .she-fixed-bottom-placeholder, /* Placeholder for fixed bottom elements */
                  .she-fixed-bottom-bar, /* Another fixed bottom bar */
                  .goods-detail__bottom-bar, /* Product detail bottom bar */
                  .product-detail-bottom-bar, /* Product detail bottom bar */
                  .sui-dialog-mask, .sui-dialog-wrap, /* Pop-up dialogs that might obscure content */
                  .she-guide-dialog, /* Guide dialogs */
                  .she-webp-guide, /* WebP guide popups */
                  .she-common-dialog, /* Common dialogs */
                  .she-common-header-placeholder,
                  .she-common-header__nav-bar--fixed,
                  .app-download-guide, /* App download banners */
                  .she-universal-header__nav-bar--fixed, /* Another fixed header variant */
                  .she-universal-header__placeholder,
                  .she-marketing-float-ball, /* Floating marketing icons */
                  .she-im-entrance, /* IM/Chat entrance */
                  .she-back-top-icon, /* Back to top button */
                  .she-activity-float-icon, /* Floating activity icons */
                  .she-common-header, /* General header that might become fixed */
                  .top-banner-container, /* Top banners */
                  div[data-v-a9590528][class*="fixed-bottom-wrapper"], /* Specific fixed bottom element */
                  /* Reduced some generic popups/banners - rely on more specific ones or accept some might appear */
                  /* div[class*="recommend-similar-entry"], */
                  /* div[class*="float-coupon-modal"], */
                  /* div[class*="new-user-guide"], */
                  /* div[class*="privacy-policy-banner"], */
                  /* div[class*="cookie-consent-banner"], */
                  /* --- Comprehensive Selectors to hide SHEIN's Add to Cart/Bag buttons --- */
                  /* Kept the most common and specific ones, removed some very generic ones */
                  .product-intro__add-cart-btn, .SProductDetailBottomToolLayout__add-cart-btn, button[ga_label="AddToBag"],
                  .detail-bottom-fixedtool__add-cart, .goods-detial__add-cart-btn, .add-to-cart-button,
                  .product-card__add-btn.price-wrapper__addbag-btn, /* زر إضافة المنتج من بطاقة المنتج */
                  a.bsc-header-cart, /* رابط السلة في الهيدر المطلوب إخفاؤه */
                  button[class*="add-to-cart"], div[class*="add-to-cart"],
                  button[class*="add-to-bag"], div[class*="add-to-bag"],
                  /* Removed .add-to-bag, .add-cart as they are too generic and might hide other things */
                  [data-qa*="add-to-bag"], [data-qa*="add-to-cart"],
                  [data-test-id*="add-to-bag"], [data-test-id*="add-to-cart"],
                  .product-intro__add-btn, .add-cart-btn, .add-to-bag-btn,
                  /* --- Comprehensive Selectors to hide SHEIN's Wishlist/Heart buttons --- */
                  .product-intro__wish-btn, .product-intro__bottom-wish, [class*="wishlist-btn"], [class*="wish-btn"],
                  .SProductDetailBottomToolLayout__wish-btn, .detail-bottom-fixedtool__wish, [data-qa*="wishlist"], [data-test-id*="wishlist"]
                   {
                    display: none !important;
                    visibility: hidden !important;
                    /* height, overflow, opacity, z-index, position are good for robust hiding */
                  }
                  body {
                    padding-bottom: 0px !important; /* Attempt to remove any padding SHEIN might add for its own bottom bar */
                    /* margin-top and padding-top for body might be too aggressive, removed for now */
                    /* margin-top: 0px !important; */
                    /* padding-top: 0px !important; */
                    overflow-y: scroll !important; /* Ensure scrolling is possible if SHEIN tries to disable it */
                  }
                  /* Ensure our webview content is not pushed down by hidden elements */
                  html, body {
                      margin-top: 0 !important;
                      padding-top: 0 !important;
                  }
                `;
                document.head.appendChild(style);
                console.log('SHEIN Custom Script: Injected CSS to hide footers/bottom navs and other elements.');
              }

              // --- NEW: Function to create and show the options bottom sheet ---
              function showProductOptionsBottomSheet() {
                  console.log('SHEIN Custom Script: Attempting to show options bottom sheet.');
                  // 1. Check if a sheet already exists, remove it
                  const existingSheet = document.getElementById('customOptionsBottomSheet');
                  if (existingSheet) {
                      existingSheet.remove();
                  }

                  // --- NEW: Reset 'data-custom-group-processed' for known specific group containers ---
                  // This allows the sheet to re-process these groups if they were marked by a previous run (e.g., by observer)
                  const specificGroupContainerSelectorsToReset = [
                      // Size selectors
                      '.goods-size ul.goods-size__sizes', '.goods-size',
                      '.product-intro__size-choose', '.product-intro__size-select', '.product-intro-sku__swatch-list--size',
                      // Color selectors
                      '#goods-color-main .goods-color__list-box ul.goods-color__imgs', '#goods-color-main',
                      '.product-intro__color-choose', '.product-intro__color-block', '.product-intro-sku__swatch-list--color'
                      // Add other specific group container selectors here if needed
                  ];
                  specificGroupContainerSelectorsToReset.forEach(selector => {
                      const el = document.querySelector(selector);
                      if (el && el.hasAttribute('data-custom-group-processed')) {
                          el.removeAttribute('data-custom-group-processed');
                          console.log(`SHEIN Custom Script: Reset 'data-custom-group-processed' for container: ${selector}`);
                      }
                  });

                  // 2. Create sheet container
                  const sheet = document.createElement('div');
                  sheet.id = 'customOptionsBottomSheet';
                  sheet.style.position = 'fixed';
                  sheet.style.bottom = '0';
                  sheet.style.left = '0';
                  sheet.style.right = '0'; // Ensure it spans width
                  sheet.style.width = '100%';
                  sheet.style.backgroundColor = 'white';
                  sheet.style.zIndex = '100000'; // Higher than FAB
                  sheet.style.padding = '20px';
                  sheet.style.boxSizing = 'border-box';
                  sheet.style.boxShadow = '0 -2px 10px rgba(0,0,0,0.2)';
                  sheet.style.maxHeight = '70vh';
                  sheet.style.overflowY = 'auto';
                  sheet.style.borderTopLeftRadius = '15px';
                  sheet.style.borderTopRightRadius = '15px';
                  sheet.style.fontFamily = '"Segoe UI", Tahoma, Geneva, Verdana, sans-serif'; // خط أفضل
                  sheet.setAttribute('dir', 'rtl'); // For RTL layout

                  let contentHTML = `<h3 style="margin-top:0; text-align:center; color:#333;">اختر الخيارات</h3>`;

                  let collectedOptionsConfig = []; 
                  let renderedGroupTitles = new Set(); // لتتبع العناوين التي تم عرضها بالفعل

                  function extractAndRenderOptionGroup(groupTitle, uniqueGroupId, containerSelectors, itemSelectors, valueSelectorOrExtractor, isMandatory, isSpecificPriorityGroup = false) {
                      let groupActuallyRenderedAndHasContent = false; // لتتبع ما إذا تم عرض المجموعة فعليًا مع محتوى
                      
                      // التحقق مما إذا كان عنوان هذه المجموعة قد تم عرضه بالكامل بالفعل في هذه النافذة السفلية
                      // تعديل: اسمح بإعادة المعالجة إذا كانت مجموعة ذات أولوية ولم يتم عرضها بعد بشكل كامل
                      if (renderedGroupTitles.has(groupTitle.toLowerCase()) && !isSpecificPriorityGroup) {
                          console.log(`SHEIN Custom Script: Non-priority group title "${groupTitle}" (uniqueId: ${uniqueGroupId}) already fully rendered. Skipping.`);
                          return;
                      }

                      let triedSelectorsLog = []; // لتسجيل المحددات التي تمت تجربتها لهذه المجموعة
                      let groupSpecificContentHTML = ''; // HTML المؤقت لهذه المجموعة (العنوان + الخيارات)

                      // تعريف المتغيرات في نطاق أوسع لتجنب ReferenceError
                      let itemsFoundInThisContainer = 0;
                      let tempItemsHtml = '';
                      let dropdown = null;
                      let optionsAddedToSelect = 0;
                      let tempSelectHtml = '';

                      for (const containerSelector of containerSelectors) {
                          triedSelectorsLog.push(containerSelector); // إضافة المحدد إلى السجل
                          const container = document.querySelector(containerSelector);
                          
                          if (container && window.getComputedStyle(container).display !== 'none' && container.offsetHeight > 0 && container.offsetParent !== null) {
                              // تعديل: اسمح بإعادة المعالجة للمجموعات ذات الأولوية إذا لم يتم عرضها بعد
                              if (container.hasAttribute('data-custom-group-processed') && !isSpecificPriorityGroup) {
                                  console.log(`SHEIN Custom Script: Non-priority container "${containerSelector}" already processed. Skipping for "${groupTitle}".`);
                                  continue;
                              }
                              // إذا كانت مجموعة ذات أولوية، يمكنها استخدام حاوية تم استخدامها من قبل مجموعة أخرى (أقل أولوية)
                              // أو إذا كانت هي نفسها قد تم وضع علامة عليها ولكن لم يتم عرضها بالكامل بعد.

                              // Define and populate 'items' for radio button options from the current container
                              let items = [];
                              for (const itemSel of itemSelectors) {
                                  // تعديل: إذا كان لونًا، ابحث عن العناصر داخل قائمة عناصر اللون المحددة (مثل ul.goods-color__imgs)
                                  // إذا كان مقاسًا، ابحث داخل (ul.goods-size__sizes)
                                  const specificListSelector = (uniqueGroupId === 'color') ? 'ul.goods-color__imgs' : (uniqueGroupId === 'size') ? 'ul.goods-size__sizes' : null;
                                  const searchContext = (specificListSelector && container.querySelector(specificListSelector))
                                                      ? container.querySelector(specificListSelector)
                                                      : container;
                                                      
                                  const foundElements = searchContext ? Array.from(searchContext.querySelectorAll(itemSel)) : [];
                                  // Filter for visible and somewhat valid items
                                  items = items.concat(foundElements.filter(el =>
                                      window.getComputedStyle(el).display !== 'none' &&
                                      el.offsetHeight > 0 &&
                                      el.offsetParent !== null &&
                                      ( // Check if item has some identifiable content
                                          (el.innerText && el.innerText.trim() !== '') ||
                                          (el.textContent && el.textContent.trim() !== '') ||
                                          el.querySelector('img[alt]') || 
                                          el.querySelector('img[title]') ||
                                          (el.getAttribute('aria-label') && el.getAttribute('aria-label').trim() !== '') ||
                                          (typeof valueSelectorOrExtractor === 'function' && valueSelectorOrExtractor(el).value && typeof valueSelectorOrExtractor(el).value === 'string' && valueSelectorOrExtractor(el).value.trim() !== '')
                                      )
                                  ));
                              }
                              items = [...new Set(items)]; // Deduplicate items, as different itemSelectors might find the same element

                              // Check if radio button items were found for the current container
                              if (items.length > 0) {
                                  collectedOptionsConfig.push({
                                      id: uniqueGroupId,
                                      title: groupTitle,
                                      selectedValue: null,
                                      isMandatory: isMandatory,
                                      type: 'radio', // Default to radio
                                      containerSelectors: containerSelectors // Store the selectors for this group
                                  });
                                  // إعادة تعيين للمتغيرات الخاصة بهذه المحاولة داخل الحلقة
                                  tempItemsHtml = ''; 
                                  itemsFoundInThisContainer = 0;
                                  let renderedOptionValuesInThisContainerAttempt = new Set(); // مجموعة محلية لتتبع القيم المعروضة في هذه المحاولة للحاوية

                                  items.forEach((item, index) => {
                                      let valueText = '';
                                      let displayHtml = '';

                                      if (typeof valueSelectorOrExtractor === 'function') {
                                          const extracted = valueSelectorOrExtractor(item);
                                          valueText = extracted.value;
                                          displayHtml = extracted.display || valueText;
                                      } else if (typeof valueSelectorOrExtractor === 'string') {
                                          const valueEl = item.querySelector(valueSelectorOrExtractor);
                                          if (valueEl) {
                                              valueText = (valueEl.innerText || valueEl.textContent || valueEl.getAttribute('alt') || valueEl.getAttribute('title') || '').trim();
                                              displayHtml = valueText;
                                              // If it's an image, try to use its alt/title for value and display it
                                              if (valueEl.tagName === 'IMG') {
                                                  displayHtml = `<img src="${valueEl.src}" alt="${valueText}" title="${valueText}" style="height: 20px; vertical-align: middle; margin-right: 5px;"> ${valueText}`;
                                              }
                                          } else {
                                               valueText = (item.innerText || item.textContent || '').trim();
                                               displayHtml = valueText;
                                          }
                                      } else { // Fallback to item's own text
                                          valueText = (item.innerText || item.textContent || '').trim();
                                          displayHtml = valueText;
                                      }
                                      
                                      // التحقق من عدم تكرار نفس قيمة الخيار ضمن هذه المجموعة والحاوية
                                      if (valueText && valueText.length < 70 && !renderedOptionValuesInThisContainerAttempt.has(valueText.toLowerCase())) {
                                          const inputId = `${uniqueGroupId}_${containerSelector.replace(/[^a-zA-Z0-9]/g, '')}_${index}`; // جعل inputId أكثر فرادة
                                          tempItemsHtml += `
                                              <label for="${inputId}" style="display: inline-block; text-align: center; padding: 8px 12px; border: 1px solid #e0e0e0; border-radius: 6px; cursor:pointer; transition: background-color 0.2s, border-color 0.2s; box-sizing: border-box; min-width: 60px; background-color: white;">
                                                  <input type="radio" name="${uniqueGroupId}" value="${valueText}" id="${inputId}" data-group-id="${uniqueGroupId}" style="display:none;">
                                                  <span style="font-size: 14px; color: #333;">${displayHtml}</span>
                                              </label>`;
                                          renderedOptionValuesInThisContainerAttempt.add(valueText.toLowerCase());
                                          itemsFoundInThisContainer++;
                                      }
                                  });
                              } else {
                                  dropdown = container.querySelector('select'); // تعيين للمتغير المعرف في النطاق الأوسع
                                  if (dropdown) {
                                      collectedOptionsConfig.push({
                                          id: uniqueGroupId,
                                          title: groupTitle,
                                          selectedValue: null,
                                          isMandatory: isMandatory,
                                          type: 'select',
                                          containerSelectors: containerSelectors, // Store the selectors for this group
                                          elementId: uniqueGroupId + '_select'
                                      });
                                      // إعادة تعيين للمتغيرات الخاصة بهذه المحاولة داخل الحلقة
                                      tempSelectHtml = `<select id="${uniqueGroupId}_select" data-group-id="${uniqueGroupId}" style="width:100%; padding:14px; border-radius:8px; border:1px solid #ccc; background-color:white; font-size: 16px; box-sizing: border-box; -webkit-appearance: menulist-button; appearance: menulist-button;">`;
                                      optionsAddedToSelect = 0;
                                      let placeholderAdded = false;
                                      Array.from(dropdown.options).forEach(opt => {
                                          const optText = opt.text.trim();
                                          const optVal = opt.value;
                                          if (optVal && optText && !opt.disabled && optVal !== '0' && optText.toLowerCase().indexOf('select') === -1 && optText.toLowerCase().indexOf('choose') === -1 && optText.toLowerCase().indexOf('اختر') === -1) {
                                              tempSelectHtml += `<option value="${optVal}">${optText}</option>`;
                                              optionsAddedToSelect++;
                                          } else if ((!optVal || optVal === '0' || opt.disabled) && optText && !placeholderAdded && (optText.toLowerCase().indexOf('select') !== -1 || optText.toLowerCase().indexOf('choose') !== -1 || optText.toLowerCase().indexOf('اختر') !== -1) ) {
                                               tempSelectHtml += `<option value="" disabled selected>${optText}</option>`; // Placeholder
                                               placeholderAdded = true;
                                          }
                                      });
                                      if(!placeholderAdded && optionsAddedToSelect > 0) { // أضف عنصرًا نائبًا عامًا إذا لم يكن أي منها مناسبًا من خيارات SHEIN وكانت هناك خيارات فعلية
                                          tempSelectHtml = tempSelectHtml.replace(`<select id="${uniqueGroupId}_select" data-group-id="${uniqueGroupId}"`, `<select id="${uniqueGroupId}_select" data-group-id="${uniqueGroupId}"><option value="" disabled selected>-- اختر ${groupTitle} --</option>`);
                                      }
                                      tempSelectHtml += `</select>`;
                                  }
                              }

                              // التحقق مما إذا تم العثور على أي خيارات (أزرار راديو أو قائمة منسدلة صالحة)
                              let hasContentFromThisContainer = false;
                              if (itemsFoundInThisContainer > 0) {
                                  // تم العثور على أزرار راديو
                                  if (uniqueGroupId === 'color') { // منطق خاص لعرض اللون بشكل قابل للطي
                                      let colorTitleText = groupTitle; // عنوان افتراضي
                                      // محاولة استخلاص عنوان اللون المحدد من الصفحة (مثل "Color: Beige")
                                      const colorTitleElement = container.querySelector('.goods-color__title .selected-color .color-block');
                                      if (colorTitleElement && colorTitleElement.innerText && colorTitleElement.innerText.trim()) {
                                          colorTitleText = colorTitleElement.innerText.trim();
                                      } else { // محاولة أخرى إذا لم ينجح المحدد الأول
                                          const altColorTitleEl = container.querySelector('.product-intro__color-show-text, .sui-color-selector__hd .sui-color-selector__val');
                                          if (altColorTitleEl && altColorTitleEl.innerText.trim()) colorTitleText = altColorTitleEl.innerText.trim();
                                      }

                                      const summaryId = uniqueGroupId + '_summary_toggle';
                                      const detailsId = uniqueGroupId + '_options_collapsible';
                                      
                                      groupSpecificContentHTML = `
                                          <div style="margin-bottom: 20px;">
                                              <h4 style="margin-top:0; margin-bottom: 12px; color:#444; font-size: 17px; padding-bottom: 8px; border-bottom: 1px dashed #e0e0e0;">${groupTitle}:</h4>
                                              <div id="${summaryId}" style="cursor: pointer; padding: 10px 12px; border: 1px solid #ccc; border-radius: 6px; display: flex; justify-content: space-between; align-items: center; background-color: #f9f9f9;">
                                                  <span style="font-size: 15px; color: #333; flex-grow: 1;">${colorTitleText}</span>
                                                  <span class="arrow" style="font-size: 1.3em; color: #555;">▼</span>
                                              </div>
                                              <div id="${detailsId}" style="display: none; padding-top: 15px; border: 1px solid #ccc; border-top: none; border-radius: 0 0 6px 6px; margin-top: -1px;">
                                                  <div style="display: flex; flex-wrap: wrap; gap: 10px; justify-content: flex-start; padding: 0 12px 12px 12px;">
                                                      ${tempItemsHtml}
                                                  </div>
                                              </div>
                                          </div>
                                      `;
                                  } else {
                                      // للمجموعات الأخرى (مثل المقاس)، يتم العرض كما كان سابقًا
                                      groupSpecificContentHTML = `<div style="margin-bottom: 20px;"><h4 style="margin-top:0; margin-bottom: 12px; color:#444; font-size: 17px; padding-bottom: 8px; border-bottom: 1px dashed #e0e0e0;">${groupTitle}:</h4>`;
                                      groupSpecificContentHTML += `<div style="display: flex; flex-wrap: wrap; gap: 10px; justify-content: flex-start;">${tempItemsHtml}</div></div>`;
                                  }
                                  
                                  // تحديث collectedOptionsConfig فقط إذا تم العثور على عناصر
                                  const existingConfigIndex = collectedOptionsConfig.findIndex(cfg => cfg.id === uniqueGroupId);
                                  // تعديل: التأكد من أننا لا نضيف config مكرر إذا تم العثور على عناصر
                                  if (existingConfigIndex !== -1) {
                                      // إذا كان موجودًا بالفعل، ربما نحدثه بدلاً من الإضافة، أو نتأكد من أن النوع صحيح
                                      collectedOptionsConfig[existingConfigIndex].type = 'radio'; // Ensure type is correct
                                  } else if (existingConfigIndex === -1) { // إضافة فقط إذا لم تكن موجودة بالفعل لهذه المجموعة
                                      collectedOptionsConfig.push({ id: uniqueGroupId, title: groupTitle, selectedValue: null, isMandatory: isMandatory, type: 'radio', containerSelectors: [containerSelector] });
                                  }
                                  hasContentFromThisContainer = true;
                              } else if (dropdown && optionsAddedToSelect > 0) {
                                  // تم العثور على قائمة منسدلة صالحة
                                  groupSpecificContentHTML = `<div style="margin-bottom: 20px;"><h4 style="margin-top:0; margin-bottom: 12px; color:#444; font-size: 17px; padding-bottom: 8px; border-bottom: 1px dashed #e0e0e0;">${groupTitle}:</h4>${tempSelectHtml}</div>`;
                                  
                                  const existingConfigIndex = collectedOptionsConfig.findIndex(cfg => cfg.id === uniqueGroupId);
                                  if (existingConfigIndex === -1) {
                                      collectedOptionsConfig.push({ id: uniqueGroupId, title: groupTitle, selectedValue: null, isMandatory: isMandatory, type: 'select', containerSelectors: [containerSelector], elementId: uniqueGroupId + '_select'});
                                  } else {
                                      collectedOptionsConfig[existingConfigIndex].type = 'select';
                                      collectedOptionsConfig[existingConfigIndex].elementId = uniqueGroupId + '_select';
                                  }
                                  hasContentFromThisContainer = true;
                              }

                              if (hasContentFromThisContainer) {
                                  // تعديل: تأكد من أن محتوى اللون الخاص يحل محل أي محتوى عام قد يكون قد تم إنشاؤه سابقًا لنفس uniqueGroupId
                                  // هذا أقل احتمالاً الآن مع renderedGroupTitles، لكنه إجراء وقائي.
                                  // الأهم هو أن groupSpecificContentHTML للون يتم إنشاؤه بشكل صحيح.
                                  contentHTML += groupSpecificContentHTML; 
                                  renderedGroupTitles.add(groupTitle.toLowerCase()); // إضافة العنوان إلى مجموعة العناوين المعروضة
                                  container.setAttribute('data-custom-group-processed', 'true'); // وضع علامة على هذه الحاوية كـ "معالجة"
                                  groupActuallyRenderedAndHasContent = true; // تم عرض المجموعة بنجاح مع محتوى
                                  console.log(`SHEIN Custom Script: Rendered options for group "${groupTitle}" (id: ${uniqueGroupId}) using container "${containerSelector}".`);
                                  
                                  // تعديل: وضع علامة على الحاويات الأصل فقط إذا لم تكن مجموعة ذات أولوية هي التي تعالجها
                                  // أو إذا كانت مجموعة ذات أولوية ولم يتم وضع علامة على الأصل بعد.
                                  // الهدف هو منع مجموعة ذات أولوية من وضع علامة على حاوية أصل عامة قد تحتاجها مجموعة أولوية أخرى.
                                  const genericWrapperSelectors = ['.product-intro-sku__swatch-list', '.goods-skuinfo__list', 'div[class*="sku-group"]', 'div[class*="option-group"]'];
                                  const genericWrapperSelectorsStr = genericWrapperSelectors.join(', ');
                                  let currentAncestor = container.parentElement;
                                  while (currentAncestor && currentAncestor !== document.body) {
                                      if (currentAncestor.matches(genericWrapperSelectorsStr)) {
                                          // لا تضع علامة على الأصل إذا كانت هذه مجموعة ذات أولوية،
                                          // إلا إذا كان الأصل هو نفسه الحاوية المباشرة للمجموعة ذات الأولوية (وهو أمر غير مرجح هنا).
                                          // الفكرة هي أن المجموعات ذات الأولوية يجب أن تضع علامة على حاوياتها المباشرة فقط.
                                          // المجموعات العامة هي التي يجب أن تكون حذرة بشأن وضع علامة على الحاويات التي قد تستخدمها مجموعات الأولوية.
                                          if (!currentAncestor.hasAttribute('data-custom-group-processed')) {
                                             // currentAncestor.setAttribute('data-custom-group-processed', 'true'); // تم التعليق مؤقتًا لتقليل التداخل
                                             // console.log(`SHEIN Custom Script: Marked ancestor container ${currentAncestor.tagName}.${currentAncestor.className || currentAncestor.id} as processed by group "${groupTitle}".`);
                                          } else {
                                             // console.log(`SHEIN Custom Script: Ancestor container ${currentAncestor.tagName}.${currentAncestor.className || currentAncestor.id} was already processed. Not re-marking for group "${groupTitle}".`);
                                          }
                                      }
                                      currentAncestor = currentAncestor.parentElement;
                                  }
                                  break; // تم العثور على حاوية عاملة لهذه المجموعة، لذا اخرج من حلقة containerSelectors
                              } else {
                                  console.log(`SHEIN Custom Script: Container "${containerSelector}" for group "${groupTitle}" found, but no usable items or dropdown options. Trying next selector for this group.`);
                              }
                          } else if (container) {
                              const styles = window.getComputedStyle(container);
                              console.log(`SHEIN Custom Script: Option container "${containerSelector}" for "${groupTitle}" found but deemed not visible/valid. Details: display=${styles.display}, offsetHeight=${container.offsetHeight}, offsetParent=${container.offsetParent === null ? 'null' : 'exists'}`);
                          } else {
                              // تسجيل إذا لم يجد المحدد أي عنصر على الإطلاق
                              console.log(`SHEIN Custom Script: Selector "${containerSelector}" for group "${groupTitle}" did NOT find any element.`);
                          }
                      }
                      if (!groupActuallyRenderedAndHasContent) { // Check if the group was actually rendered with content
                          console.warn(`SHEIN Custom Script: No visible/valid container OR no usable items found for option group "${groupTitle}". Tried container selectors: ${triedSelectorsLog.join('; ')}`);
                          // NEW: Add more prominent warning for specific groups
                          if (uniqueGroupId === 'size' || uniqueGroupId === 'color') {
                              console.warn(`SHEIN Custom Script: CRITICAL - Could not render MANDATORY group: "${groupTitle}" (ID: ${uniqueGroupId}). Check selectors and page structure. Tried selectors: ${triedSelectorsLog.join('; ')}`);
                          }
                      }
                  }

                  // --- ترتيب استدعاء المجموعات: اللون والمقاس كمجموعات ذات أولوية ---
                  extractAndRenderOptionGroup('اللون', 'color',
                      [
                        '#goods-color-main', // حاوية اللون الرئيسية من HTML المقدم
                        '.product-intro__color-choose', // حاويات ألوان شائعة أخرى
                        '.product-intro__color-block', '.product-intro-sku__swatch-list--color', 
                        '.product-sku-selector--color', '.goods-skuinfo__list[data-sku-name*="color" i]', 
                        'div[class*="color-selector"]', 'div[data-attr-name*="Color"]', '.product-intro__color-show', 
                      ],
                      [
                        'li.goods-color__img-item', // عنصر اللون من HTML المقدم (داخل ul.goods-color__imgs)
                        '.product-intro__color-item', '.product-intro-sku__item', '.sui-color-selector__item', 
                        '.product-sku-selector__item', '.goods-skuinfo__item', 'div[class*="color-item"]', 
                        'button[class*="color-item"]',
                      ],
                      function(item) { // دالة استخلاص قيمة اللون (صور + اسم)
                          let value = '', display = '';
                          // الأولوية لـ aria-label على عنصر li نفسه (كما في HTML المقدم)
                          const ariaLabel = item.getAttribute('aria-label');
                          if (ariaLabel && ariaLabel.trim()) {
                              value = ariaLabel.trim();
                          }

                          const imgElement = item.querySelector('img.crop-image-container__img');
                          let imgSrc = null;
                          if (imgElement) {
                              imgSrc = imgElement.getAttribute('data-src') || imgElement.src;
                              if (imgSrc && (imgSrc.includes('bg-logo') || imgSrc.includes('data:image/gif') || !imgSrc.startsWith('http'))) {
                                  imgSrc = null; 
                              }
                              if (!value && imgElement.alt && imgElement.alt.trim()) value = imgElement.alt.trim(); // fallback لـ alt الصورة
                              if (!value && imgElement.title && imgElement.title.trim()) value = imgElement.title.trim(); // fallback لـ title الصورة
                          }
                          if (!value) value = 'لون غير مسمى';

                          display = imgSrc ? `<img src="${imgSrc}" alt="${value}" title="${value}" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; display: block; margin: 0 auto; border: 1px solid #eee;">` : value;
                          if (imgSrc && value !== 'لون غير مسمى' && value.length < 20) display += `<span style="font-size:10px; display:block; text-align:center; margin-top:3px; color:#555; max-width: 40px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${value}</span>`;
                          return { value: value, display: display || value };
                      }, true, true ); // isMandatory = true, isSpecificPriorityGroup = true

                  // --- Define Option Groups ---
                  extractAndRenderOptionGroup('المقاس', 'size',
                      [
                        '.goods-size ul.goods-size__sizes', // New from provided HTML (primary target)
                        '.goods-size', // Main container for new HTML structure, good fallback for the whole size section
                        '.product-intro__size-choose', '.product-intro__size-select', '.product-intro-sku__swatch-list--size', 
                        '.product-sku-selector--size', '.goods-skuinfo__list[data-sku-name*="size" i]', 
                        'div[class*="size-selector"]', 'div[data-attr-name*="Size"]', '.product-intro__size', 
                        // '.goods-size__wrapper', // This is inside .goods-size, so .goods-size is broader
                        // '.SIZE_ITEM_HOOK' // This is the ul itself, covered by '.goods-size ul.goods-size__sizes'
                        // '.product-intro__bsSize', // Often too generic or part of a larger component
                        // '[da-eid="2fnem0ivt24"]', // Too specific, likely to break
                        // '.purchase-control' // Too broad, can cause issues if it contains color too
                      ],
                      [
                        'li.goods-size__sizes-item', // New item selector from provided HTML - should be primary
                        '.product-intro__size-radio', '.product-intro__size-item', '.product-intro-sku__item', 
                        '.product-sku-selector__item', '.goods-skuinfo__item', 'div[class*="size-item"]', // Keep existing for broader compatibility
                        'button[class*="size-item"]', 'li', '.size-item.product-intro__size', 
                        // '.size-radio', // Often a wrapper, covered by more specific item selectors
                        // '.product-intro__size-radio.fsp-element' // Too specific
                      ], // دالة استخلاص قيمة المقاس (نص)
                      function(item) { 
                          let valueText = '';
                          // let displayHtml = ''; // displayHtml سيكون نفس valueText للمقاس
                          let targetElement = item; // 'item' is the element matched by itemSelectors

                          // Special handling for older structures if 'item' is a known wrapper
                          if (item.matches('span.size-radio') && item.querySelector('div.product-intro__size-radio')) {
                              targetElement = item.querySelector('div.product-intro__size-radio');
                          }
                          // For the new HTML, 'item' is 'li.goods-size__sizes-item'.

                          // Extraction Priority:
                          // 1. 'aria-item' (كما في HTML المقدم لـ li.goods-size__sizes-item)
                          if (targetElement.hasAttribute('aria-item')) {
                              valueText = (targetElement.getAttribute('aria-item') || '').trim();
                          }

                          // 2. 'data-attr_value' (كما في HTML المقدم لـ li.goods-size__sizes-item)
                          if (!valueText && targetElement.hasAttribute('data-attr_value')) {
                              valueText = (targetElement.getAttribute('data-attr_value') || '').trim();
                          }

                          // 3. Specific inner text elements (add new one, keep others)
                          // p.goods-size__sizes-item-text is the primary display text for the new structure
                          const innerTextEl = targetElement.querySelector(
                              'p.goods-size__sizes-item-text, ' + // New from provided HTML
                              'p.product-intro__size-radio-inner, .product-intro__size-radio-text, ' +
                              '.product-intro-sku__item-text, .product-sku-selector__item-text, ' +
                              '.goods-skuinfo__item-text, .size-item__title'
                          );
                          if (innerTextEl) {
                              valueText = (innerTextEl.innerText || innerTextEl.textContent || '').trim() || valueText; // Use existing valueText as fallback
                          }
                          // 4. 'aria-label' attribute (common attribute, lower priority if text found)
                          if (!valueText && targetElement.hasAttribute('aria-label')) {
                              valueText = (targetElement.getAttribute('aria-label') || '').trim();
                          }

                          // 5. 'data-attr_value_name' attribute (another SHEIN specific attribute)
                          if (!valueText && targetElement.hasAttribute('data-attr_value_name')) {
                              valueText = (targetElement.getAttribute('data-attr_value_name') || '').trim();
                          }
                          
                          // 6. Fallback to targetElement's own innerText (or original item's if targetElement was changed)
                          if (!valueText) {
                              let textToUse = (targetElement.innerText || targetElement.textContent || '').trim();
                              if (!textToUse && item !== targetElement) { // If targetElement's text is empty and it was different from original item
                                  textToUse = (item.innerText || item.textContent || '').trim();
                              }
                              // Only use this fallback if it's reasonably short and doesn't contain newlines
                              if (textToUse.length > 0 && textToUse.length < 70 && !textToUse.includes('\n')) {
                                  valueText = textToUse;
                              }
                          }
                          
                          // Final Default: If no valid text found after all attempts
                          if (!valueText) {
                              valueText = 'غير محدد';
                          }
                          
                          return { value: valueText, display: valueText }; // display هو نفس value للمقاس
                      },
                      true, // isMandatory
                      true  // isSpecificPriorityGroup
                  );
                  
                  // Attempt to find other generic SKU groups
                  document.querySelectorAll('.product-intro-sku__swatch-list, .goods-skuinfo__list, div[class*="sku-group"], div[class*="option-group"]').forEach((container, idx) => {
                      // This loop finds potential *main* containers for generic options.
                      if (container && window.getComputedStyle(container).display !== 'none' && container.offsetHeight > 0 && container.offsetParent !== null) {
                          // Enhanced checks to prevent processing already covered areas
                          // Check 1: If the container itself has been processed
                          if (container.hasAttribute('data-custom-group-processed')) {
                              console.log(`SHEIN Custom Script: Generic container (itself: ${container.tagName}.${container.className || container.id}) at index ${idx} was already processed. Skipping.`);
                              return; 
                          }
                          // Check 2: If any descendant of this container has been processed
                          // This handles cases where a specific option group (e.g., size) processed a child element,
                          // and now the generic loop is looking at a parent of that processed child.
                          if (container.querySelector('[data-custom-group-processed="true"]')) {
                              console.log(`SHEIN Custom Script: Generic container (${container.tagName}.${container.className || container.id}) at index ${idx} CONTAINS an already processed element. Skipping.`);
                              return;
                          }
                          // Check 3: If this container is a child of an already processed element (i.e., an ancestor is processed).
                          // The `closest()` method checks the element itself and its ancestors.
                          const closestProcessedAncestor = container.closest('[data-custom-group-processed="true"]');
                          if (closestProcessedAncestor && closestProcessedAncestor !== container) { // Ensure it's an ancestor, not self (already covered by Check 1)
                              console.log(`SHEIN Custom Script: Generic container (${container.tagName}.${container.className || container.id}) at index ${idx} IS A CHILD of an already processed element (${closestProcessedAncestor.tagName}.${closestProcessedAncestor.className || closestProcessedAncestor.id}). Skipping.`);
                              return;
                          }

                          let groupName = 'خيار إضافي ' + (idx + 1); // Default generic name
                          let uniqueId = 'other_opt_' + idx;
                          let potentialTitle = '';

                          const titleElement = container.previousElementSibling || container.querySelector('.sku-title, .option-title, .label, .attr-name, .sku-name, .product-intro-sku__title-text');
                          if (titleElement && titleElement.innerText) {
                              potentialTitle = titleElement.innerText.trim().replace(':', '');
                          }

                          if (potentialTitle) {
                              // If this potential title has ALREADY been rendered by any previous call (specific or generic), skip this container.
                              if (renderedGroupTitles.has(potentialTitle.toLowerCase())) {
                                  console.log(`SHEIN Custom Script: Generic container at index ${idx} has title "${potentialTitle}" which matches an already rendered group. Skipping.`);
                                  return;
                              }
                              // Also, if it looks like a specific group title that *should* have been handled.
                              if (potentialTitle.toLowerCase().includes('size') || potentialTitle.toLowerCase().includes('مقاس') ||
                                  potentialTitle.toLowerCase().includes('color') || potentialTitle.toLowerCase().includes('لون')) {
                                  console.log(`SHEIN Custom Script: Generic container at index ${idx} has title "${potentialTitle}" which looks like Size/Color. Assuming handled or will be skipped by renderedGroupTitles. Skipping this generic attempt.`);
                                  return;
                              }
                              if (potentialTitle.length < 30 && potentialTitle.length > 0) { // Basic validity for a title
                                groupName = potentialTitle;
                                uniqueId = potentialTitle.toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '') + '_' + idx;
                              } else if (potentialTitle.length >= 30) {
                                 console.log(`SHEIN Custom Script: Generic container at index ${idx} has a long title "${potentialTitle}". Using default name "${groupName}".`);
                                 // Falls through to use default groupName
                              }
                              // If potentialTitle was empty, it also falls through to use default groupName
                          } else {
                              console.log(`SHEIN Custom Script: Generic container at index ${idx} has no discernible title. Using default name "${groupName}".`);
                              // Falls through to use default groupName
                          }
                          
                          // The extractAndRenderOptionGroup function will perform the final check against renderedGroupTitles.

                          extractAndRenderOptionGroup(groupName, uniqueId,
                              [container], // Pass the container itself
                              // Simplified item selectors for generic options
                              ['.product-intro-sku__item', '.goods-skuinfo__item', '[role="radio"]', '[role="option"]', 'div[class*="option-item"]'],
                              // Removed 'li' and 'button' as they are too generic for items
                              '.product-intro-sku__item-text, .goods-skuinfo__item-text, span:not([class])', // Value selector
                              true, // Assume mandatory for now
                              false // isSpecificPriorityGroup = false for generic groups
                          );
                      }
                  });

                  // بناء HTML النهائي للنافذة السفلية
                  // contentHTML يحتوي الآن على جميع مجموعات الخيارات التي تم إنشاؤها
                  // (اللون والمقاس أولاً، ثم أي مجموعات عامة أخرى)
                  let finalSheetHTML = `<h3 style="margin-top:0; margin-bottom: 20px; text-align:center; color:#1a1a1a; font-size: 20px; padding-bottom: 15px; border-bottom: 1px solid #eee;">اختر الخيارات</h3>`;
                  finalSheetHTML += contentHTML; // إضافة مجموعات الخيارات
                  
                  finalSheetHTML += `
                      <div id="optionsErrorMsg" style="color: red; margin-bottom: 10px; text-align: center; display: none; padding: 8px; border: 1px solid red; border-radius: 4px; background-color: #ffebee;"></div>
                      <button id="confirmAddToCartInSheet" style="background-color: #28a745; color: white; padding: 14px 20px; border: none; border-radius: 8px; cursor: pointer; width: 100%; font-size: 17px; font-weight: bold; margin-bottom:10px; transition: background-color 0.2s ease;">إضافة إلى السلة</button>
                      <button id="cancelOptionsSheet" style="background-color: #f0f0f0; color: #333; padding: 12px 20px; border: 1px solid #ccc; border-radius: 8px; cursor: pointer; width: 100%; font-size: 16px; transition: background-color 0.2s ease;">إلغاء</button>
                  `;
                  // Append the rest of the contentHTML (buttons and error message div)
                  const tempDiv = document.createElement('div');
                  tempDiv.innerHTML = finalSheetHTML; 
                  sheet.innerHTML = ''; // مسح أي محتوى قديم في sheet
                  while(tempDiv.firstChild) { sheet.appendChild(tempDiv.firstChild); }

                  document.body.appendChild(sheet);

                  // Helper function for styling a radio button's label
                  function styleRadioLabel(labelElement, isChecked) {
                      if (!labelElement) return; // Safety check
                      if (isChecked) {
                          labelElement.style.backgroundColor = '#e3f2fd'; // Light blue for selected
                          labelElement.style.borderColor = '#2196F3'; // Blue border for selected
                          labelElement.style.color = '#2196F3'; // Blue text for selected
                          labelElement.style.fontWeight = 'bold';
                      } else {
                          labelElement.style.backgroundColor = 'white';
                          labelElement.style.borderColor = '#e0e0e0';
                          labelElement.style.color = '#333';
                          labelElement.style.fontWeight = 'normal';
                      }
                  }

                  // Add click effect and initial styling for radio button labels
                  sheet.querySelectorAll('label[for^="size_"], label[for^="color_"], label[for^="other_opt_"]').forEach(labelEl => {
                      const input = labelEl.querySelector('input[type="radio"]');
                      if (!input) return;
                      
                      labelEl.onclick = (e) => { 
                          const radioName = input.name;
                          // Set .checked property for all radio buttons in the group
                          // and update the style of their corresponding labels.
                          sheet.querySelectorAll(`input[name="${radioName}"]`).forEach(radioInGroup => {
                              radioInGroup.checked = (radioInGroup === input);
                              styleRadioLabel(radioInGroup.parentElement, radioInGroup.checked);
                          });
                      };
                      // Initial style update
                      styleRadioLabel(labelEl, input.checked);
                  });
                  
                  // --- Add event listener for collapsible color section ---
                  const colorSummaryToggle = sheet.querySelector('#color_summary_toggle');
                  if (colorSummaryToggle) {
                      colorSummaryToggle.onclick = function() {
                          const detailsDiv = sheet.querySelector('#color_options_collapsible');
                          const arrowSpan = this.querySelector('.arrow');
                          if (detailsDiv) {
                              if (detailsDiv.style.display === 'none' || detailsDiv.style.display === '') {
                                  detailsDiv.style.display = 'block';
                                  if(arrowSpan) arrowSpan.textContent = '▲';
                              } else {
                                  detailsDiv.style.display = 'none';
                                  if(arrowSpan) arrowSpan.textContent = '▼';
                              }
                          }
                      };
                  }

                  const confirmBtn = document.getElementById('confirmAddToCartInSheet');
                  confirmBtn.onmouseover = function() { this.style.backgroundColor = '#218838'; };
                  confirmBtn.onmouseout = function() { this.style.backgroundColor = '#28a745'; };
                  confirmBtn.addEventListener('click', function() {
                      let allMandatorySelected = true;
                      let missingOptionsMessages = [];
                      const errorMsgDiv = document.getElementById('optionsErrorMsg');
                      errorMsgDiv.style.display = 'none';
                      errorMsgDiv.innerText = '';

                      collectedOptionsConfig.forEach(optGroup => {
                          let selectedValueInGroup = null;
                          let activeClassFound = false; // To check for 'active' or 'selected' classes

                          if (optGroup.type === 'radio') {
                              const checkedRadio = sheet.querySelector(`input[name="${optGroup.id}"]:checked`);
                              if (checkedRadio) {
                                  selectedValueInGroup = checkedRadio.value;
                              }
                              // Also check the original page elements for active classes, as the sheet might not reflect clicks on page
                              // This is more for the `areProductOptionsSelected` logic, but good to be aware of
                              const originalContainer = optGroup.containerSelectors ? document.querySelector(optGroup.containerSelectors.find(cs => document.querySelector(cs))) : null; // Find the first valid container using stored selectors
                              if (originalContainer) {
                                  const activeItemInOriginal = originalContainer.querySelector(
                                    'li.goods-size__sizes-item.active, li.goods-size__sizes-item.selected, ' + // For new size structure
                                    'li.goods-color__img-item.color-active, ' + // For new color structure
                                    '.product-intro__size-radio--active, .product-intro__color-item--active, .product-intro-sku__item--current' // Existing
                                  );
                                  if (activeItemInOriginal) activeClassFound = true;
                              }

                          } else if (optGroup.type === 'select') {
                              const selectElement = sheet.querySelector(`#${optGroup.elementId}`);
                              if (selectElement && selectElement.value) {
                                  selectedValueInGroup = selectElement.value;
                              }
                          }
                          
                          if (optGroup.isMandatory && !selectedValueInGroup && !activeClassFound) {
                              allMandatorySelected = false;
                              if (!missingOptionsMessages.includes(optGroup.title)) {
                                missingOptionsMessages.push(optGroup.title);
                              }
                          }
                          optGroup.selectedValue = selectedValueInGroup;
                      });

                      if (allMandatorySelected) {
                          var name = '', basePrice = '', image = '', currency = '';
                          var nameSelectors = [
                            '.goods-name .detail-title-text', // New from provided HTML
                            'h1.detail-title-h1 span.detail-title-text', // Also from new HTML, more specific
                            'h1.product-intro__head-name', '.product-intro__head-name', '.goods-title-new', 
                            '.goods-name h1', '.product-name', 
                            '.title-text__content', '.product-title'
                            // Removed 'h1[class*="name"]' and 'h1' as they are too generic
                          ];
                          for (let s of nameSelectors) { try { let el = document.querySelector(s); if (el && el.innerText.trim()) { name = el.innerText.trim().split('\\n')[0]; break; } } catch(e){} }

                          const priceSelectors = [
                            '#productMainPriceId span', // New from provided HTML
                            '.productPrice__main span', // Also from new HTML (inside #productMainPriceId)
                            '.product-intro__head-price .price .value', '.product-intro__price-val', // Common
                            '.sale-price__val', // Often used for the final price
                            '.goods-price__key', // Another common one
                            '.current-price', '.product-price', '.price__value' // General price classes
                          ];
                          let priceData = { price: '', currency: '' };
                          for (let s of priceSelectors) {
                              try {
                                  let el = document.querySelector(s);
                                  if (el && el.innerText && el.innerText.trim()) {
                                      let fullPriceText = el.innerText.trim(); // Keep this line
                                      priceData = _parsePriceString(fullPriceText);
                                      if (priceData.price) break;
                                  }
                              } catch (e) {}
                          }
                          basePrice = priceData.price;
                          currency = priceData.currency;

                          var imgSelectors = [
                            '.goods-detail-top__CarouselsBeltBox .swiper-slide-active img', // Attempt to get main image from carousel (if swiper is used)
                            '#goods-color-main li.goods-color__img-item.color-active img.crop-image-container__img', // Image of selected color (new HTML)
                            '#goods-color-main li.goods-color__img-item img.crop-image-container__img', // First color image if none selected (new HTML)
                            '.goods-detail-top__CarouselsBeltBox img', // Any image in carousel box (fallback)
                            '.product-intro__main-img img', '.crop-image-container img', // Common main image selectors
                            'div.product-intro__main-img-ctn img.animation-image__img', // Specific animated image
                            '.she-product-image-viewer__main-img', // Viewer image
                            '.swiper-slide-active .goods-img__image' // Active image in a swiper
                            // Removed very generic ones like img[alt*="product"], img[class*="product-image"]
                          ];
                          for (let s of imgSelectors) { try { let el = document.querySelector(s); if (el && el.src) { image = el.src; break; } } catch(e){} }
                          if (!image && document.querySelector('img')) { try { image = document.querySelector('img').src; } catch(e){} }

                          const selectedSizeOpt = collectedOptionsConfig.find(opt => opt.id === 'size');
                          const selectedColorOpt = collectedOptionsConfig.find(opt => opt.id === 'color');
                          
                          let finalSize = selectedSizeOpt ? selectedSizeOpt.selectedValue : '';
                          let finalColor = selectedColorOpt ? selectedColorOpt.selectedValue : '';
                          
                          // You could also gather other selected options if needed:
                          // let otherSelectedOptions = {};
                          // collectedOptionsConfig.filter(opt => opt.id !== 'size' && opt.id !== 'color' && opt.selectedValue).forEach(opt => {
                          //    otherSelectedOptions[opt.title] = opt.selectedValue;
                          // });
                          // Then pass otherSelectedOptions or a string representation of them.

                          console.log('SHEIN Custom Script: Adding to cart from sheet -> Name:', name, 'Price:', basePrice, 'Currency:', currency, 'Image:', image, 'Size:', finalSize, 'Color:', finalColor);
                          if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
                              window.flutter_inappwebview.callHandler('addToCartHandler', name, basePrice, image, finalSize, finalColor, currency)
                                  .then(function(result) { console.log('SHEIN Custom Script: addToCartHandler call successful from sheet, result:', result); })
                                  .catch(function(error) { console.error('SHEIN Custom Script: Error calling addToCartHandler from sheet:', error); });
                          } else {
                              console.error('SHEIN Custom Script: flutter_inappwebview.callHandler is not available (from sheet).');
                          }
                          sheet.remove();
                      } else {
                          errorMsgDiv.innerText = 'يرجى تحديد: ' + missingOptionsMessages.join('، ');
                          errorMsgDiv.style.display = 'block';
                          console.log('SHEIN Custom Script: Missing mandatory options in sheet:', missingOptionsMessages.join(', '));
                      }
                  });

                  const cancelBtn = document.getElementById('cancelOptionsSheet');
                  cancelBtn.onmouseover = function() { this.style.backgroundColor = '#e6e6e6'; };
                  cancelBtn.onmouseout = function() { this.style.backgroundColor = '#f0f0f0'; };
                  cancelBtn.addEventListener('click', function() {
                      sheet.remove();
                  });
              }

              // --- Helper function to convert Eastern Arabic/Persian numerals to Western numerals ---
              function _easternArabicToWesternNumerals(str) {
                if (typeof str !== 'string') return str; // Return as is if not a string
                return str.replace(/[٠١٢٣٤٥٦٧٨٩]/g, function(d) { // Eastern Arabic numerals (٠-٩)
                  return (d.charCodeAt(0) - 1632).toString();
                }).replace(/[۰۱۲۳۴۵۶۷۸۹]/g, function(d) { // Persian numerals (۰-۹)
                  return (d.charCodeAt(0) - 1776).toString();
                });
              }
              // --- Helper function to parse price string and extract currency ---
              function _parsePriceString(textWithPrice) {
                if (!textWithPrice || typeof textWithPrice !== 'string') return { price: '', currency: '' };
                let priceVal = '';
                let currencyVal = '';
                const lcTextWithPrice = textWithPrice.toLowerCase();

                // --- Currency Extraction (uses original textWithPrice) ---
                // Try to extract currency symbol/code first
                const currencyRegex = /([A-Z]{2,3}|SR|SAR|AED|KWD|BHD|OMR|QAR|USD|EUR|GBP|JPY|CAD|AUD|CNY|₹|د\.إ|ر\.س|﷼|دينار|درهم|دولار|يورو|جنيه|ين|£|€|\$|¥)/i;
                let currencyMatch = textWithPrice.match(currencyRegex); // Match on original text for case-sensitive symbols like 'ر.س'
                
                if (currencyMatch && currencyMatch[0]) {
                    let match = currencyMatch[0]; // النص الفعلي الذي تطابق مع التعبير النمطي
                    let lcMatch = match.toLowerCase(); // نسخة بأحرف صغيرة للمقارنة

                    // الأولوية الأولى: تحويل المصطلحات العربية الشائعة والرموز المحددة إلى أكواد قياسية
                    if (['ر.س', 'ريال', '﷼'].includes(lcMatch) || lcMatch === 'sr') { // "sr" غالباً ما تستخدم لـ SAR
                        currencyVal = 'SAR';
                    } else if (['د.إ', 'درهم'].includes(lcMatch)) {
                        currencyVal = 'AED';
                    } else if (match === '₹') {
                        currencyVal = 'INR'; // الروبية الهندية
                    } else if (match === '$') { // غامض، ولكنه غالباً USD
                        currencyVal = 'USD';
                    } else if (match === '€') {
                        currencyVal = 'EUR';
                    } else if (match === '£') {
                        currencyVal = 'GBP';
                    } else if (match === '¥') { // غامض (JPY/CNY)
                        currencyVal = 'JPY'; // الافتراضي إلى الين الياباني
                    }
                    // الأولوية الثانية: إذا كان بالفعل كود قياسي من 2-3 أحرف كبيرة من التعبير النمطي، استخدمه
                    // (القائمة تشمل الأكواد المعروفة التي يدعمها التعبير النمطي)
                    else if (/^[A-Z]{2,3}$/.test(match) && 
                             ['SAR', 'AED', 'KWD', 'BHD', 'OMR', 'QAR', 'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CNY'].includes(match)) {
                        currencyVal = match;
                    }
                    // الأولوية الثالثة: معالجة النسخ الصغيرة من الأكواد القياسية
                    else if (['sar', 'kwd', 'bhd', 'omr', 'qar', 'usd', 'eur', 'gbp', 'jpy', 'cad', 'aud', 'cny'].includes(lcMatch)) {
                        currencyVal = lcMatch.toUpperCase();
                    }
                    // إذا لم يتم تحديد currencyVal بعد كل هذا، ستبقى فارغة، وهو سلوك احتياطي آمن.
                }

                // Extract numeric part
                let textForNumericExtraction = _easternArabicToWesternNumerals(textWithPrice); // Convert numerals for price extraction
                let numericMatch = textForNumericExtraction.match(/[\d.,]+/);
                if (numericMatch && numericMatch[0]) {
                    let numStr = numericMatch[0];
                    if (numStr.includes(',') && numStr.includes('.')) {
                        if (numStr.lastIndexOf(',') > numStr.lastIndexOf('.')) { // Format: 1.234,56
                            numStr = numStr.replace(/\./g, '').replace(',', '.');
                        } else { // Format: 1,234.56
                            numStr = numStr.replace(/,/g, '');
                        }
                    } else if (numStr.includes(',')) { // Only comma present
                        if (numStr.substring(numStr.lastIndexOf(',') + 1).length <= 2 && numStr.match(/,/g).length === 1) {
                            numStr = numStr.replace(',', '.'); // e.g., "123,45" -> "123.45"
                        } else {
                            numStr = numStr.replace(/,/g, ''); // e.g., "1,234" -> "1234"
                        }
                    }
                    if ((numStr.match(/\./g) || []).length > 1) { // Ensure only one decimal point (last one)
                        numStr = numStr.replace(/\.(?=.*\.)/g, '');
                    }
                    priceVal = numStr;
                } else { // Fallback for digits only if no dots/commas
                    let digitsOnlyMatch = textForNumericExtraction.match(/\d+/);
                    if (digitsOnlyMatch && digitsOnlyMatch[0]) priceVal = digitsOnlyMatch[0];
                }
                return { price: priceVal, currency: currencyVal };
              }
              // --- Function to check if product options like size/color are selected ---
              function areProductOptionsSelected() {
                  let optionsMissing = false;
                  let missingMessages = []; // لتخزين أسماء الخيارات الناقصة
                  console.log('SHEIN Custom Script: [areProductOptionsSelected] Starting validation.');

                  // Helper to check a group of options
                  function checkOptionGroup(groupTitle, containerSelectors, selectedSelectors, isMandatory) {
                      let containerFoundAndVisible = false;
                      let optionSelectedInThisGroup = false;
                      let checkedContainerSelector = null; // لتسجيل أي حاوية تم معالجتها

                      for (const containerSelector of containerSelectors) {
                          const container = document.querySelector(containerSelector);
                          // التحقق من أن الحاوية موجودة ومرئية فعلاً في التخطيط
                          if (container && window.getComputedStyle(container).display !== 'none' && container.offsetHeight > 0 && container.offsetParent !== null) {
                              containerFoundAndVisible = true;
                              checkedContainerSelector = containerSelector;
                              console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] Found VISIBLE option container with selector: ${containerSelector}`);

                              // 1. التحقق من وجود كلاسات محددة تشير إلى الاختيار
                              for (const selectedSelector of selectedSelectors) {
                                  if (container.querySelector(selectedSelector)) {
                                      optionSelectedInThisGroup = true;
                                      console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] Found selected option via class: ${selectedSelector}`);
                                      break;
                                  }
                              }

                              // 2. التحقق من القوائم المنسدلة (إذا لم يتم العثور على خيار محدد بعد)
                              if (!optionSelectedInThisGroup) {
                                  const dropdown = container.querySelector('select');
                                  if (dropdown) {
                                      console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] Found dropdown. Value: "${dropdown.value}", SelectedIndex: ${dropdown.selectedIndex}`);
                                      // عادةً ما يكون الخيار الأول (index 0) هو عنصر نائب
                                      if (dropdown.value && dropdown.value !== '' && dropdown.value !== '0' && dropdown.selectedIndex > 0) {
                                          const selectedOptionElement = dropdown.options[dropdown.selectedIndex];
                                          if (selectedOptionElement && !selectedOptionElement.disabled) {
                                              const optionText = selectedOptionElement.innerText.trim().toLowerCase();
                                              // تجنب النصوص النائبة الشائعة
                                              if (optionText && !optionText.includes('select') && !optionText.includes('choose') && !optionText.includes('الرجاء اختيار') && !optionText.includes('اختر')) {
                                                  optionSelectedInThisGroup = true;
                                                  console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] Found selected option in dropdown: "${dropdown.value}", Text: "${selectedOptionElement.innerText.trim()}"`);
                                              } else {
                                                  console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] Dropdown option "${optionText}" looks like a placeholder.`);
                                              }
                                          } else {
                                               console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] Dropdown option at index ${dropdown.selectedIndex} is disabled or invalid.`);
                                          }
                                      } else {
                                          console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] Dropdown value is empty, "0", or selectedIndex is 0.`);
                                      }
                                  }
                              }
                              
                              // 3. التحقق من سمات ARIA (إذا لم يتم العثور على خيار محدد بعد)
                              if (!optionSelectedInThisGroup) {
                                  const ariaSelectedElement = container.querySelector('[aria-selected="true"], [aria-checked="true"]');
                                  if (ariaSelectedElement) {
                                      optionSelectedInThisGroup = true;
                                      console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] Found selected option via ARIA attribute.`);
                                  }
                              }

                              break; // تمت معالجة أول حاوية مرئية لهذه المجموعة
                          } else if (container) {
                              // تسجيل إذا تم العثور على الحاوية ولكنها غير مرئية
                              console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] Found option container with selector: ${containerSelector}, but it's NOT VISIBLE (display: ${window.getComputedStyle(container).display}, offsetHeight: ${container.offsetHeight}, offsetParent: ${container.offsetParent}).`);
                          }
                      }

                      if (!containerFoundAndVisible) {
                          console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] No visible container found for this option group.`);
                      }

                      if (isMandatory && containerFoundAndVisible && !optionSelectedInThisGroup) {
                          optionsMissing = true;
                          if (!missingMessages.includes(groupTitle)) {
                              missingMessages.push(groupTitle);
                          }
                          console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] MANDATORY option group found (via ${checkedContainerSelector}) but NO selection detected.`);
                      } else if (containerFoundAndVisible && optionSelectedInThisGroup) {
                          console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] Option group found (via ${checkedContainerSelector}) and a selection WAS detected.`);
                      } else if (isMandatory && !containerFoundAndVisible) {
                          // هذه الحالة معقدة. إذا لم يتم العثور على مجموعة إجبارية، هل يجب أن نمنع الإضافة؟
                          // حاليًا، نفترض أنه إذا لم تكن موجودة في الصفحة، فهي غير قابلة للتطبيق.
                          // console.log(`SHEIN Custom Script: [checkOptionGroup - ${groupTitle}] MANDATORY option group NOT found. Assuming not applicable.`);
                      }
                      return optionSelectedInThisGroup || !containerFoundAndVisible; // صحيح إذا تم الاختيار أو إذا لم تكن هناك خيارات مرئية/موجودة
                  }

                  // Check for Size (usually mandatory if present)
                  checkOptionGroup('المقاس',
                      // قائمة موسعة من المحددات لحاويات المقاس
                      [
                        '.goods-size ul.goods-size__sizes', // New from provided HTML (primary target for items)
                        '.goods-size', // Main container for new HTML (overall size section)
                        '.product-intro__size-choose', '.product-intro__size-select', 
                        '.product-intro-sku__swatch-list--size', '.product-sku-selector--size', 
                        'div[class*="size-selector"]', // Generic but usually safe for size containers
                        'div[data-attr-name*="Size"]', 'div[class*="select-size"]' // Existing
                      ],
                      // قائمة موسعة من المحددات لحالات المقاس المحدد (ابحث عن كلاس 'active' أو 'selected' أو سمات ARIA)
                      [
                        'li.goods-size__sizes-item.active', 'li.goods-size__sizes-item.selected', // New from provided HTML (assuming 'active' or 'selected' class)
                        '.product-intro__size-radio--active', '.product-intro__size-item--active', 
                        '.product-intro-sku__item--current', '.sui-select-curr__val:not([data-placeholder])', 
                        '.product-sku-selector__item--active', 'div[class*="size-item"][class*="selected"]', 
                        'div[class*="size-item"][class*="active"]', 'button[class*="size-item"][aria-checked="true"]'
                      ],
                      true
                  );

                  // Check for Color (usually mandatory if present)
                  checkOptionGroup('اللون',
                      // قائمة موسعة من المحددات لحاويات اللون
                      [
                        '#goods-color-main .goods-color__list-box ul.goods-color__imgs', // New from provided HTML (primary target for items)
                        '#goods-color-main', // Main container for new HTML (overall color section)
                        '.product-intro__color-choose', '.product-intro__color-block', 
                        '.product-intro-sku__swatch-list--color', '.product-sku-selector--color', 
                        'div[class*="color-selector"]', // Generic but usually safe for color containers
                        'div[data-attr-name*="Color"]', 'div[class*="select-color"]' // Existing
                      ],
                      // قائمة موسعة من المحددات لحالات اللون المحدد (ابحث عن كلاس 'color-active' أو سمات ARIA)
                      [
                        'li.goods-color__img-item.color-active', // New from provided HTML (selected item has 'color-active' class)
                        '.product-intro__color-item--active', '.product-intro-sku__item--current', 
                        '.sui-color-selector__item--active', '.product-sku-selector__item--active', 
                        'div[class*="color-item"][class*="selected"]', 'div[class*="color-item"][class*="active"]', 'button[class*="color-item"][aria-checked="true"]'
                      ],
                      true
                  );
                  
                  // التحقق من مجموعات SKU العامة (الخيارات الأخرى)
                  document.querySelectorAll('.product-intro-sku__swatch-list, .goods-skuinfo__list, div[class*="sku-group"], div[class*="option-group"]').forEach(container => {
                      // التأكد من أن الحاوية مرئية
                      if (window.getComputedStyle(container).display !== 'none' && container.offsetHeight > 0 && container.offsetParent !== null) {
                          // محاولة استخلاص اسم لمجموعة الخيارات هذه
                          let groupName = 'خيار'; // اسم افتراضي
                          const titleElement = container.previousElementSibling || container.querySelector('.sku-title, .option-title, .label, .attr-name, .sku-name'); // البحث عن عنوان
                          if (titleElement && titleElement.innerText) {
                              let tempName = titleElement.innerText.trim().replace(':', '');
                              if (tempName && tempName.length < 30) groupName = tempName; // تحقق أساسي من طول العنوان
                          }
                          
                          // تجنب إعادة التحقق من المجموعات التي تم التعامل معها بالفعل (المقاس/اللون) بناءً على الاسم
                          if (groupName.toLowerCase().includes('size') || groupName.toLowerCase().includes('مقاس') || groupName.toLowerCase().includes('color') || groupName.toLowerCase().includes('لون')) {
                              console.log(`SHEIN Custom Script: [Generic SKU Check] Skipping group "${groupName}" as it seems to be Size/Color.`);
                              return; // تخطي إذا كانت تبدو كمجموعة مقاس/لون تم التعامل معها
                          }

                          // التحقق مما إذا كان أي عنصر داخل هذه المجموعة العامة محددًا
                          const isSelected = container.querySelector('.product-intro-sku__item--current, .goods-skuinfo__item--select, .sui-select-curr__val:not([data-placeholder]), [aria-selected="true"], [aria-checked="true"], [class*="selected"], [class*="active"]');
                          
                          if (!isSelected) {
                              // قبل وضع علامة، تحقق مما إذا كانت قائمة منسدلة مع تحديد عنصر نائب
                              const dropdown = container.querySelector('select');
                              if (dropdown) {
                                  if (dropdown.value && dropdown.value !== '' && dropdown.value !== '0' && dropdown.selectedIndex > 0) {
                                       const selectedOptionElement = dropdown.options[dropdown.selectedIndex];
                                       if (selectedOptionElement && !selectedOptionElement.disabled) {
                                          const optionText = selectedOptionElement.innerText.trim().toLowerCase();
                                          if (optionText && !optionText.includes('select') && !optionText.includes('choose') && !optionText.includes('الرجاء اختيار') && !optionText.includes('اختر')) {
                                              console.log(`SHEIN Custom Script: [Generic SKU Check - ${groupName}] Dropdown option selected: "${optionText}"`);
                                              return; // تم تحديد الخيار في القائمة المنسدلة، لذا لا تضع علامة
                                          }
                                       }
                                  }
                              }

                              // إذا لم يتم العثور على تحديد بعد، ولم تكن موجودة بالفعل في missingMessages
                              if (!missingMessages.includes(groupName)) {
                                  optionsMissing = true;
                                  missingMessages.push(groupName);
                                  console.log(`SHEIN Custom Script: [Generic SKU Check] Generic option group "${groupName}" (container: ${container.className || container.tagName}) seems unselected.`);
                              }
                          } else {
                               console.log(`SHEIN Custom Script: [Generic SKU Check] Generic option group "${groupName}" (container: ${container.className || container.tagName}) HAS a selected item.`);
                          }
                      }
                  });

                  if (optionsMissing && missingMessages.length > 0) {
                      // تسجيل في الكونسول لتأكيد أن التنبيه سيظهر
                      console.log('SHEIN Custom Script: [areProductOptionsSelected] Validation FAILED. Missing options:', missingMessages.join(' و '));
                      alert('يرجى تحديد ' + missingMessages.join(' و ') + ' أولاً من صفحة المنتج.');
                      return false; // Indicates options are missing
                  }
                  // تأكيد: إذا وصلنا إلى هنا، فهذا يعني أن جميع الخيارات الإجبارية المطلوبة قد تم تحديدها،
                  // أو أن المنتج لا يحتوي على خيارات إجبارية.
                  console.log('SHEIN Custom Script: [areProductOptionsSelected] Validation PASSED. All required product options appear selected or are not present.');
                  return true; // All detected required options are selected, or no options detected
              }


              // --- Function to handle "Add to Cart" button replacement and data extraction ---
              function setupCustomAddToCartButton() {
                console.log('SHEIN Custom Script: Attempting to setup custom "Add to Cart" button.');
                const customBtnId = 'customSheinAddToCartBtn';

                // If custom button already exists, ensure original is hidden and exit
                function findOriginalSheinButton() {
                    const selectors = [
                        '#ProductDetailAddBtnForFloorPrice', // ID
                        '.product-intro__add-cart-btn', // Product detail
                        '.SProductDetailBottomToolLayout__add-cart-btn', // Mobile product detail
                        '.goods-detial__add-cart-btn', // Another mobile product detail
                        'button[ga_label="AddToBag"]', // GA label
                        '.add-to-cart-button', // Generic class
                        '.product-card__add-bag', // Product listing cards
                        'button[class*="add-to-cart"]', 'button[class*="addtocart"]',
                        'button[class*="add-to-bag"]', 'button[class*="addtobag"]',
                        '.goods-add-cart-btn', // another common class
                        '.pdp-button-text', // text inside a button
                        '.add-to-bag',
                        '.add-cart',
                        'button[data-qa="add-to-bag"]', // data-qa attribute
                        '.product-intro__add-btn', // another intro button class
                        '.detail-bottom-fixedtool__add-cart' // fixed tool add cart
                    ];
                    for (let selector of selectors) {
                        try {
                            let elem = document.querySelector(selector);
                            if (elem) {
                                console.log('SHEIN Custom Script: Found original button by selector:', selector);
                                let clickableParent = elem.closest('button, [role="button"], a');
                                return clickableParent || elem;
                            }
                        } catch (e) { console.warn('SHEIN Custom Script: Error with selector:', selector, e); }
                    }
                    // Fallback: findElementByText (already defined if needed, but less reliable)
                    /*
                    function findElementByText(tag, text) { // Define if not globally available
                      var elements = Array.from(document.getElementsByTagName(tag));
                      for (var i = 0; i < elements.length; i++) {
                        if (elements[i].innerText && elements[i].innerText.trim().toUpperCase() === text.toUpperCase()) {
                          return elements[i];
                        }
                      }
                      return null;
                    }
                    */
                    console.log('SHEIN Custom Script: Falling back to text-based search for "ADD TO CART" or "ADD TO BAG".');
                    let btnByText = null; // Simplified, as findElementByText might not be defined here.
                    // ... (original findElementByText logic if you want to keep it) ...
                    if (btnByText) {
                        console.log('SHEIN Custom Script: Found by text search:', btnByText.tagName, btnByText.innerText.trim());
                        let clickableParent = btnByText.closest('button, [role="button"], a');
                        return clickableParent || btnByText;
                    }
                    console.log('SHEIN Custom Script: Did not find original "ADD TO CART/BAG" button via any method.');
                    return null;
                }

                if (document.getElementById(customBtnId)) {
                  console.log('SHEIN Custom Script: Custom button already exists. Assuming it is correctly positioned.');
                  return;
                }

                // var originalSheinButton = findOriginalSheinButton(); // We might not need to find original if FAB is always used

                var btn = document.createElement('button');
                btn.id = customBtnId;
                btn.innerHTML = '<svg viewBox="0 0 24 24" style="width:32px; height:32px; vertical-align: middle;"><path fill="currentColor" d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zm10 0c-1.1 0-1.99.9-1.99 2S15.9 22 17 22s2-.9 2-2-.9-2-2-2zm-1.45-5c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.37-.66-.11-1.48-.87-1.48H5.21l-.94-2H1v2h2l3.6 7.59-1.35 2.44C4.52 15.37 5.48 17 7 17h12v-2H7l1.1-2h7.45z"/></svg>'; // أيقونة سلة ممتلئة
                btn.style.color = '#ffffff';
                btn.style.border = 'none';
                btn.style.cursor = 'pointer';
                btn.style.boxSizing = 'border-box';
                btn.style.display = 'flex';
                btn.style.alignItems = 'center';
                btn.style.justifyContent = 'center';
                btn.style.backgroundColor = '#FFC107'; // اللون الكهرماني (Accent Color)
                btn.style.width = '60px';
                btn.style.height = '60px';
                btn.style.borderRadius = '50%';
                btn.style.boxShadow = '0 4px 8px rgba(0,0,0,0.25)';
                btn.style.position = 'fixed';
                const flutterNavHeight = window.flutterBottomNavHeight || 56.0;
                btn.style.bottom = (flutterNavHeight + 15) + 'px';
                btn.style.right = '20px';
                btn.style.zIndex = '99998'; // Ensure it's below the options sheet but above most page content
                document.body.appendChild(btn);
                console.log('SHEIN Custom Script: Custom FAB-style (right-aligned, green, circular) button added to document.body.');

                btn.addEventListener('click', function(event) {
                  event.preventDefault();
                  event.stopPropagation();
                  console.log('SHEIN Custom Script: Custom "إضافة إلى السلة" FAB clicked');

                  // --- Call the function to show the options bottom sheet ---
                  showProductOptionsBottomSheet();
                });
              }

              // Remove or comment out the old direct data extraction from the FAB click listener.
              // The `areProductOptionsSelected` function is also no longer directly called by the FAB.
              // It can be removed if not used as a helper elsewhere, or kept if you want to pre-fill the sheet.
              // For this implementation, the sheet starts fresh.

              /*
              // --- Function to check if product options like size/color are selected ---
              // This function is NO LONGER CALLED by the FAB.
              // It could potentially be used to pre-select options in the new bottom sheet if desired.
              function areProductOptionsSelected() {
                  // ... (original implementation of areProductOptionsSelected) ...
                  // For now, we are not using it directly for the FAB click.
                  // The new bottom sheet handles its own validation.
                  console.log("SHEIN Custom Script: areProductOptionsSelected is now for reference or potential pre-selection, not direct FAB validation.");
                  return true; // Or implement pre-selection logic
              }
              */

              // --- Original setupCustomAddToCartButton (before modification for bottom sheet) ---
              /*
              function setupCustomAddToCartButton_OLD() {
                console.log('SHEIN Custom Script: Attempting to setup custom "Add to Cart" button.');
                const customBtnId = 'customSheinAddToCartBtn';

                if (document.getElementById(customBtnId)) {
                  console.log('SHEIN Custom Script: Custom button already exists. Assuming it is correctly positioned.');
                  return;
                }

                function findElementByText(tag, text) {
                  var elements = Array.from(document.getElementsByTagName(tag));
                  for (var i = 0; i < elements.length; i++) {
                    if (elements[i].innerText && elements[i].innerText.trim().toUpperCase() === text.toUpperCase()) {
                      return elements[i];
                    }
                  }
                  return null;
                }

                function findOriginalSheinButton() {
                    const selectors = [
                        // ... (original selectors) ...
                    ];
                    for (let selector of selectors) {
                        try {
                            let elem = document.querySelector(selector);
                            if (elem) {
                                console.log('SHEIN Custom Script: Found original button by selector:', selector);
                                let clickableParent = elem.closest('button, [role="button"], a');
                                return clickableParent || elem;
                            }
                        } catch (e) { console.warn('SHEIN Custom Script: Error with selector:', selector, e); }
                    }
                    console.log('SHEIN Custom Script: Falling back to text-based search for "ADD TO CART" or "ADD TO BAG".');
                    let btnByText = findElementByText('button', 'ADD TO CART') ||
                                    findElementByText('div', 'ADD TO CART') ||
                                    findElementByText('span', 'ADD TO CART') ||
                                    findElementByText('button', 'ADD TO BAG') ||
                                    findElementByText('div', 'ADD TO BAG') ||
                                    findElementByText('span', 'ADD TO BAG');
                    if (btnByText) {
                        console.log('SHEIN Custom Script: Found by text search:', btnByText.tagName, btnByText.innerText.trim());
                        let clickableParent = btnByText.closest('button, [role="button"], a');
                        return clickableParent || btnByText;
                    }
                    console.log('SHEIN Custom Script: Did not find original "ADD TO CART/BAG" button via any method.');
                    return null;
                }

                  var btn = document.createElement('button');
                  btn.id = customBtnId;
                  // --- تعديل: استخدام أيقونة SVG لسلة التسوق ---
                  btn.innerHTML = '<svg viewBox="0 0 24 24" style="width:32px; height:32px; vertical-align: middle;"><path fill="currentColor" d="M15.55 13c.75 0 1.41-.41 1.75-1.03l3.58-6.49A.996.996 0 0 0 20.01 4H5.21l-.94-2H1v2h2l3.6 7.59-1.35 2.44C4.52 15.37 5.48 17 7 17h12v-2H7l1.1-2h7.45zM6.16 6h12.15l-2.76 5H8.53L6.16 6zM7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zm10 0c-1.1 0-1.99.9-1.99 2S15.9 22 17 22s2-.9 2-2-.9-2-2-2z"/></svg>';
                  // Styling for the custom button
                  btn.style.color = '#ffffff';
                  btn.style.border = 'none';
                  btn.style.cursor = 'pointer';
                  btn.style.boxSizing = 'border-box';
                  
                  // Use flex to center text inside the button
                  btn.style.display = 'flex';
                  btn.style.alignItems = 'center';
                  btn.style.justifyContent = 'center';

                  // --- تعديل: استخدام استراتيجية الزر الثابت دائمًا وتغيير التنسيق والموقع ---
                  console.log('SHEIN Custom Script: Using fixed custom button strategy (FAB style).');
                  
                  // Styling for a FAB-like button
                  btn.style.backgroundColor = '#4CAF50'; // لون أخضر جميل (يمكنك اختيار درجة أخرى)
                  btn.style.color = '#ffffff';
                  btn.style.width = '60px'; // عرض الزر
                  btn.style.height = '60px'; // ارتفاع الزر
                  btn.style.borderRadius = '50%'; // لجعله دائريًا
                  btn.style.boxShadow = '0 4px 8px rgba(0,0,0,0.25)'; // ظل للزر
                  
                  // Positioning
                  btn.style.position = 'fixed';
                  const flutterNavHeight = window.flutterBottomNavHeight || 56.0; // استخدام ارتفاع شريط التنقل السفلي من Flutter
                  btn.style.bottom = (flutterNavHeight + 15) + 'px'; // 15px فوق شريط Flutter
                  btn.style.right = '20px'; // 20px من الحافة اليمنى
                  // إزالة الخصائص التي توسطنه سابقًا
                  // btn.style.left = '50%';
                  // btn.style.transform = 'translateX(-50%)';
                  // btn.style.width = 'calc(100% - 40px)';
                  // btn.style.maxWidth = '380px';
                  // btn.style.padding = '12px 20px';
                  // btn.style.borderRadius = '8px';
                  // btn.style.fontSize = '16px';
                  // btn.style.textAlign = 'center';
                  btn.style.zIndex = '99998'; // High z-index
                  document.body.appendChild(btn); // Append to body for fixed positioning
                  console.log('SHEIN Custom Script: Custom FAB-style (right-aligned, green, circular) button added to document.body.');
                  // --- نهاية التعديل ---

                  btn.addEventListener('click', function(event) {
                    event.preventDefault();
                    event.stopPropagation();
                    console.log('SHEIN Custom Script: Custom "إضافة إلى السلة" button clicked');
                    // --- THIS IS WHERE THE OLD LOGIC WAS ---
                    // --- NOW IT'S HANDLED BY showProductOptionsBottomSheet ---
                    
                    var name = '', price = '', image = '', size = '', color = '', currency = '';
                    var nameSelectors = [
                        'h1.product-intro__head-name', '.product-intro__head-name', '.goods-title-new', '.goods-name', 
                        'h1[class*="name"]', '.product-name', 'h1', '.title-text__content', '.product-title',
                        '.goods-name-new__main' // More specific for some layouts
                    ];
                    for (let s of nameSelectors) { 
                        try { let el = document.querySelector(s); if (el && el.innerText.trim()) { name = el.innerText.trim().split('\\n')[0]; console.log('Name by ' + s + ':', name); break; } } catch(e){} 
                    }
                    // Price extraction
                    const priceSelectors = [
                        '.product-intro__head-price .price .value', '.product-intro__price-val', '.original-price__main-price', 
                        '.price-real', '.sale-price__val', '.goods-price__normal', '.goods-price__key', 
                        '.price-layout__value', '.current-price', '.product-price', '.product-intro__head-pricebox .price', 
                        '.price__value', '.price-num', '.goods-price__key-new' // Added more selectors
                    ];
                    let priceData = { price: '', currency: '' };
                    for (let s of priceSelectors) {
                        try {
                            let el = document.querySelector(s);
                            if (el && el.innerText && el.innerText.trim()) {
                                let fullPriceText = el.innerText.trim();
                                console.log('Full Price Text by ' + s + ':', fullPriceText);
                                priceData = _parsePriceString(fullPriceText);
                                if (priceData.price) {
                                    console.log('Parsed Price Data by ' + s + ' -> Price:', priceData.price, 'Currency:', priceData.currency);
                                    break; 
                                }
                            }
                        } catch (e) { console.warn('SHEIN Custom Script: Error processing price selector ' + s, e); }
                    }
                    if (!priceData.price) { // Fallback if selectors didn't yield a price
                        console.log('SHEIN Custom Script: Price not found by primary selectors, trying generic fallback.');
                        try {
                            let potentialPriceElements = Array.from(document.querySelectorAll('span, div, p, strong, b'))
                                .filter(el => el.innerText && /\d/.test(el.innerText) && (el.offsetWidth > 0 || el.offsetHeight > 0) && el.innerText.trim().length < 100);

                            for (let pElem of potentialPriceElements) {
                                let tempPriceData = _parsePriceString(pElem.innerText.trim());
                                if (tempPriceData.price) {
                                    priceData = tempPriceData; // Take the first plausible one
                                    console.log('Price by generic fallback:', priceData.price, 'Currency:', priceData.currency, 'from element:', pElem.tagName, 'Text:', pElem.innerText.trim());
                                    if (priceData.currency) break; // Prefer if currency is also found
                                }
                            }
                        } catch (e) { console.warn('SHEIN Custom Script: Error in generic price fallback', e); }
                    }
                    price = priceData.price;
                    currency = priceData.currency;
                    var imgSelectors = ['.product-intro__main-img img', '.crop-image-container img', 'div.product-intro__main-img-ctn img.animation-image__img', 'img.j-magnify-image', '.she-product-image-viewer__main-img', '.swiper-slide-active .goods-img__image', '.spp-image-viewer__img-current', 'img[alt*="product"]', 'img[class*="product-image"]', '.gallery-item-current img', '.goods-detail-img__normal', '.product-image__element', '.sui-image-viewer__img'];
                    for (let s of imgSelectors) { try { let el = document.querySelector(s); if (el && el.src) { image = el.src; console.log('Image by ' + s + ':', image); break; } } catch(e){} }
                    if (!image && document.querySelector('img')) { try { image = document.querySelector('img').src; console.log('Image by first img tag:', image); } catch(e){} }

                    var sizeSelectors = [
                        '.product-intro__size-select .product-intro__size-radio--active .product-intro__size-radio-text',
                        '.product-intro__size-select .sui-select-curr__val',
                        '.product-intro__size .product-intro__size-item--active span',
                        '.size-list .active', '.size-list .on',
                        '.product-intro__size-choose .product-intro__size-choose-text',
                        '.product-intro-sku__item--current .product-intro-sku__item-text',
                        '.product-sku-selector__item--active .product-sku-selector__item-text',
                        '.goods-skuinfo__item--select .goods-skuinfo__item-text',
                        // More specific for selected size/option text
                        '.product-intro-sku__value-text--current', '.product-intro__size-radio--active .product-intro__size-radio-text',
                        'div[class*="size-item"][class*="active"] span',
                        '.selected-size-value',
                        '.product-intro-sku__value-text--current'
                    ];
                    for (let s of sizeSelectors) { try { let el = document.querySelector(s); if (el && el.innerText.trim()) { size = el.innerText.trim(); console.log('Size by ' + s + ':', size); break; } } catch(e){} }
                    if (!size) {
                        try {
                            // Try to find a label for "Size" or "Model" and get its selected value
                            let sizeLabel = Array.from(document.querySelectorAll('div[class*="sku-name"], span[class*="sku-name"], dt[class*="sku-name"]'))
                                                .find(el => el.innerText && (el.innerText.trim().toLowerCase().includes('size') || el.innerText.trim().toLowerCase().includes('model')));
                            if (sizeLabel) {
                                // Look for a sibling or child that indicates the selected value
                                let skuContainer = sizeLabel.closest('.product-intro-sku__swatch, .goods-skuinfo__item');
                                if (skuContainer) {
                                   let selectedValueElement = skuContainer.querySelector('.product-intro-sku__item--current .product-intro-sku__item-text, .goods-skuinfo__item--select .goods-skuinfo__item-text, .sui-select-curr__val');
                                   if (selectedValueElement && selectedValueElement.innerText.trim()) size = selectedValueElement.innerText.trim();
                                   console.log('Size by label and selected value:', size);
                                }
                            }
                        } catch(e){}
                    }                    
                    var colorSelectors = [
                        '.product-intro__color-item--active .product-intro__color-name',
                        '.product-intro__color-block .sui-color-selector__val',
                        '.product-intro__color-show .product-intro__color-show-text',
                        // More specific for selected color text or image alt/title
                        '.product-intro-sku__swatch-list--color .product-intro-sku__item--current .product-intro-sku__item-text',
                        '.goods-skuinfo__list[data-sku-name*="color" i] .goods-skuinfo__item--select .goods-skuinfo__item-text',
                        '.product-intro__color-item--active img[alt]', // Get alt from active color image
                        '.product-intro__color-item--active img[title]', // Get title from active color image
                        '.selected-color-value',
                        '.product-intro-sku__value-text--current' 
                    ];
                    for (let s of colorSelectors) {
                        try {
                            let elem = document.querySelector(s);
                            if (elem) {
                                let potentialColor = (elem.alt || elem.title || elem.innerText || elem.textContent || '').trim();
                                if (potentialColor && potentialColor.toLowerCase() !== size.toLowerCase()) { 
                                    color = potentialColor;
                                    console.log('Color by ' + s + ':', color);
                                    break;
                                }
                            }
                        } catch(e){}
                    }
                    if (!color) {
                        try {
                            // Try to find a label for "Color" and get its selected value
                            let colorLabel = Array.from(document.querySelectorAll('div[class*="sku-name"], span[class*="sku-name"], dt[class*="sku-name"]'))
                                                .find(el => el.innerText && el.innerText.trim().toLowerCase().includes('color'));
                            if (colorLabel) {
                                let skuContainer = colorLabel.closest('.product-intro-sku__swatch, .goods-skuinfo__item');
                                if (skuContainer) {
                                   let selectedValueElement = skuContainer.querySelector('.product-intro-sku__item--current .product-intro-sku__item-text, .goods-skuinfo__item--select .goods-skuinfo__item-text, .sui-select-curr__val, .product-intro__color-item--active img');
                                   if (selectedValueElement) color = (selectedValueElement.alt || selectedValueElement.title || selectedValueElement.innerText || selectedValueElement.textContent || '').trim();
                                   console.log('Color by label and selected value:', color);
                                }
                            }
                        } catch(e){}
                    }

                    console.log('SHEIN Custom Script: Extracted Data -> Name:', name, 'Price:', price, 'Currency:', currency, 'Image:', image, 'Size:', size, 'Color:', color);
                    if (window.flutter_inappwebview && typeof window.flutter_inappwebview.callHandler === 'function') {
                      window.flutter_inappwebview.callHandler('addToCartHandler', name, price, image, size, color, currency)
                        .then(function(result) { console.log('SHEIN Custom Script: addToCartHandler call successful, result:', result); })
                        .catch(function(error) { console.error('SHEIN Custom Script: Error calling addToCartHandler:', error); });
                    } else { // هذا الجزء مهم للتأكد من أن الـ handler متاح
                      console.error('SHEIN Custom Script: flutter_inappwebview.callHandler is not available.');
                    }
                  });
              }
              */

              function hideSheinElements() {
                const selectors = `
                    .footer-container, .footer, .bottom-nav, .sui-bottom-nav,
                    .she-bottom-bar, .common-footer, #footer, [class*="footer"], [id*="footer"],
                    .detail-bottom-fixedtool-container,
                    .she-common-navigation-bar,
                    .layout-bottom-nav-new,
                    .SProductDetailBottomToolLayout,
                    .she-float-entry,
                    .float-layer-container,
                    .she-fixed-bottom-placeholder,
                    .she-fixed-bottom-bar,
                    .goods-detail__bottom-bar,
                    .product-detail-bottom-bar,
                    .sui-dialog-mask, .sui-dialog-wrap,
                    .she-guide-dialog,
                    .she-webp-guide,
                    .she-common-dialog,
                    .app-download-guide,
                    .she-universal-header__nav-bar--fixed,
                    .she-universal-header__placeholder,
                    .she-marketing-float-ball,
                    .she-im-entrance,
                    .she-back-top-icon,
                    .she-activity-float-icon,
                    .she-common-header,
                    .top-banner-container,
                    div[data-v-a9590528][class*="fixed-bottom-wrapper"],
                    /* Reduced some generic popups/banners to match CSS block */
                    /* div[class*="recommend-similar-entry"], */
                    /* div[class*="float-coupon-modal"], */
                    /* div[class*="new-user-guide"], */
                    /* div[class*="privacy-policy-banner"], */
                    /* div[class*="cookie-consent-banner"], */
                    /* --- Comprehensive Selectors to hide SHEIN's Add to Cart/Bag buttons (ensure this list matches the CSS block) --- */
                    /* Kept the most common and specific ones, removed some very generic ones to match CSS block */
                    .product-intro__add-cart-btn, .SProductDetailBottomToolLayout__add-cart-btn, button[ga_label="AddToBag"],
                    .detail-bottom-fixedtool__add-cart, .goods-detial__add-cart-btn, .add-to-cart-button,
                    .product-card__add-btn.price-wrapper__addbag-btn, /* زر إضافة المنتج من بطاقة المنتج */
                    'a.bsc-header-cart', /* رابط السلة في الهيدر المطلوب إخفاؤه - تأكد من استخدام علامات اقتباس للمحددات المعقدة في JS */
                    button[class*="add-to-cart"], div[class*="add-to-cart"],
                    button[class*="add-to-bag"], div[class*="add-to-bag"],
                    /* Removed .add-to-bag, .add-cart as they are too generic */
                    [data-qa*="add-to-bag"], [data-qa*="add-to-cart"],
                    [data-test-id*="add-to-bag"], [data-test-id*="add-to-cart"],
                    .product-intro__add-btn, .add-cart-btn, .add-to-bag-btn,
                    /* --- Comprehensive Selectors to hide SHEIN's Wishlist/Heart buttons (ensure this list matches the CSS block) --- */
                    .product-intro__wish-btn, .product-intro__bottom-wish, [class*="wishlist-btn"], [class*="wish-btn"],
                    .SProductDetailBottomToolLayout__wish-btn, .detail-bottom-fixedtool__wish, [data-qa*="wishlist"], [data-test-id*="wishlist"]
                `;
                let count = 0;
                try {
                    // The CSS injection should handle most of this. This JS is a fallback.
                    // No changes to the JS hiding logic itself, but the 'selectors' string is now shorter.
                    document.querySelectorAll(selectors).forEach(nav => { /* ... existing hiding logic ... */ });
                } catch (e) { console.error("SHEIN Custom Script: Error hiding elements:", e); }
                if (count > 0) console.log('SHEIN Custom Script: Ensured ' + count + ' SHEIN elements are hidden (via JS).');
                else console.log('SHEIN Custom Script: All targeted SHEIN elements already appear hidden (checked by JS).');
              }

              const observerCallback = function(mutationsList, observer) {
                for(const mutation of mutationsList) {
                    if (mutation.type === 'childList' || mutation.type === 'attributes') {
                        hideSheinElements();
                        if (!document.getElementById('customSheinAddToCartBtn') &&
                            (document.querySelector('.product-intro') || document.querySelector('.goods-detail') || document.querySelector('.SProductDetailLayout') || document.querySelector('.product-detail-container'))) {
                            console.log('SHEIN Custom Script: Mutation detected, attempting to re-setup custom button.');
                            setupCustomAddToCartButton();
                        }
                        // Optimization: if we've processed a relevant mutation, no need to check others in this batch
                        // This might be too aggressive if multiple important things change at once.
                        // For now, let it run through all mutations in the list.
                    }
                }
              };
              
              // Ensure observer is created only once
              if (!window.sheinCustomObserver) {
                window.sheinCustomObserver = new MutationObserver(observerCallback);
                const config = { attributes: true, childList: true, subtree: true, attributeFilter: ['style', 'class', 'id'] };
                
                function startObserver() {
                  if (document.body) {
                    window.sheinCustomObserver.observe(document.body, config);
                    console.log('SHEIN Custom Script: MutationObserver started on document.body.');
                    // Initial setup after observer is ready
                    hideSheinElements();
                    if (document.querySelector('.product-intro') || document.querySelector('.goods-detail') || document.querySelector('.SProductDetailLayout') || document.querySelector('.product-detail-container')) {
                       setupCustomAddToCartButton();
                    }
                  } else {
                    console.log('SHEIN Custom Script: document.body not ready, retrying observer start.');
                    setTimeout(startObserver, 150);
                  }
                }

                if (document.readyState === 'loading') {
                  document.addEventListener('DOMContentLoaded', startObserver);
                } else {
                  startObserver();
                }
              }


              // Initial and delayed calls for robustness
              hideSheinElements();
              if (document.querySelector('.product-intro') || document.querySelector('.goods-detail') || document.querySelector('.SProductDetailLayout') || document.querySelector('.product-detail-container')) {
                 setupCustomAddToCartButton();
              }

              setTimeout(() => {
                console.log('SHEIN Custom Script: Delayed re-check (1s).');
                hideSheinElements();
                if (!document.getElementById('customSheinAddToCartBtn') && (document.querySelector('.product-intro') || document.querySelector('.goods-detail') || document.querySelector('.SProductDetailLayout') || document.querySelector('.product-detail-container'))) {
                  setupCustomAddToCartButton();
                }
              }, 1000);
              setTimeout(() => {
                console.log('SHEIN Custom Script: Delayed re-check (3s).');
                hideSheinElements();
                 if (!document.getElementById('customSheinAddToCartBtn') && (document.querySelector('.product-intro') || document.querySelector('.goods-detail') || document.querySelector('.SProductDetailLayout') || document.querySelector('.product-detail-container'))) {
                  setupCustomAddToCartButton();
                }
              }, 3000);

              // A less frequent interval check as a final fallback
              if (!window.sheinCustomInterval) {
                window.sheinCustomInterval = setInterval(() => {
                  console.log('SHEIN Custom Script: Periodic interval check (10s).');
                  hideSheinElements();
                  if (!document.getElementById('customSheinAddToCartBtn') &&
                      (document.querySelector('.product-intro') || document.querySelector('.goods-detail') || document.querySelector('.SProductDetailLayout') || document.querySelector('.product-detail-container'))) {
                      setupCustomAddToCartButton();
                  }
                }, 10000);
              }

            })();
            """;

          try {
            // تمرير ارتفاع شريط التنقل السفلي من Flutter إلى JavaScript
            final double bottomAppBarHeight = kBottomNavigationBarHeight;
            await controller.evaluateJavascript(source: "window.flutterBottomNavHeight = \${bottomAppBarHeight};");
            print("SHEIN Custom Script: flutterBottomNavHeight set to \${bottomAppBarHeight}");
            await controller.evaluateJavascript(source: jsCode);
            print("SHEIN Custom Script: Injected/Re-injected successfully.");
          } catch (e) {
            print("خطأ في حقن جافاسكريبت: \$e");
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 22),
              color: _canGoBack ? Theme.of(context).primaryColor : Colors.grey,
              onPressed: _canGoBack ? () {
                webViewController.goBack();
              } : null,
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 22),
              color: _canGoForward ? Theme.of(context).primaryColor : Colors.grey,
              onPressed: _canGoForward ? () {
                webViewController.goForward();
              } : null,
            ),
            IconButton(
              icon: Icon(Icons.refresh, size: 24),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                webViewController.reload();
              },
            ),
            IconButton(
              icon: Icon(Icons.home_outlined, size: 24),
              color: Theme.of(context).primaryColor,
              onPressed: () {
                webViewController.loadUrl(urlRequest: URLRequest(url: WebUri('https://m.shein.com/')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddToCart(List<dynamic> args) {
    if (args.length >= 5) {
      try {
        String name = args[0]?.toString() ?? 'اسم غير معروف';
        String? rawPrice = args[1]?.toString();
        String price = (rawPrice?.isEmpty ?? true) ? '0' : rawPrice!;
        String image = args[2]?.toString() ?? '';
        String size = args[3]?.toString() ?? 'مقاس غير محدد';
        String color = args[4]?.toString() ?? '';
        String currency = args.length > 5 ? args[5]?.toString() ?? '' : '';

        final product = Product(
          name: name,
          price: price,
          image: image,
          size: size,
          color: color,
          currencySymbol: currency,
        );
        _addProductToCart(product);
      } catch (e) {
        print('Error handling add to cart: $e');
      }
    }
  }

  Future<void> _addProductToCart(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartList = prefs.getStringList('cart') ?? [];
    List<Product> currentCartItems = cartList
        .map((jsonStr) {
          try {
            return Product.fromMap(jsonDecode(jsonStr));
          } catch (e) {
            print("خطأ في فك ترميز منتج: $jsonStr, الخطأ: $e");
            return null;
          }
        })
        .where((p) => p != null)
        .cast<Product>()
        .toList();

    int existingProductIndex = currentCartItems.indexWhere((p) =>
        p.name == product.name &&
        p.price == product.price &&
        p.size == product.size &&
        p.color == product.color &&
        p.currencySymbol == product.currencySymbol);

    if (existingProductIndex != -1) {
      currentCartItems[existingProductIndex].quantity++;
    } else {
      currentCartItems.add(product);
    }

    List<String> updatedCartJsonList = currentCartItems.map((p) => jsonEncode(p.toMap())).toList();
    await prefs.setStringList('cart', updatedCartJsonList);
    setState(() {
      _cartItemCount = currentCartItems.length;
    });
  }

  void _showSearchByLinkDialog(BuildContext context) {
    final TextEditingController _urlController = TextEditingController();
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('بحث عن منتج بالرابط'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('الرجاء إدخال رابط المنتج:'),
                SizedBox(height: 8),
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(hintText: 'https://m.shein.com/...'),
                  keyboardType: TextInputType.url,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('بحث'),
              onPressed: () {
                final String url = _urlController.text.trim();
                if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
                  webViewController.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('الرابط غير صالح. يرجى التأكد من أنه يبدأ بـ http:// أو https://')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareCurrentPage() async {
    if (webViewController != null) {
      WebUri? currentUrl = await webViewController.getUrl();
      if (currentUrl != null && currentUrl.toString().isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('مشاركة: ${currentUrl.toString()}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن مشاركة الصفحة الحالية.')),
        );
      }
    }
  }
}
