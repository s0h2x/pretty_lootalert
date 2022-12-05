local L, private = ...;
local next = next;
local setmetatable = setmetatable;
local GetLocale = GetLocale;
local LOCALE = GetLocale();

private.locales = {
	["YOU_RECEIVED_LABEL"] = {
		ruRU = "Ваша добыча",
		enGB = "You receive",
		esMX = "Has recibido",
		deDE = "Ihr habt erhalten",
		frFR = "Vous avez reçu",
		itIT = "Ottieni",
		koKR = "다음을 획득했습니다.",
		ptBR = "Você recebeu",
		zhCN = "你获得了",
		zhTW = "你獲得"
	},
	["YOU_WON_LABEL"] = {
		ruRU = "Вы выиграли!",
		enGB = "You Won!",
		esMX = "Has ganado!",
		deDE = "Gewonnen!",
		frFR = "Gagné!",
		itIT = "Hai vinto!",
		koKR = "획득!",
		ptBR = "Você venceu!",
		zhCN = "你获得了!",
		zhTW = "你贏得了!"
	},
	["YOU_CREATED_LABEL"] = {
		ruRU = "Вы создаете:",
		enGB = "You create:",
		esMX = "Creas:",
		deDE = "Ihr stellt her:",
		frFR = "Vous créez :",
		itIT = "Hai creato:",
		koKR = "만들었습니다:",
		ptBR = "Você cria:",
		zhCN = "你制造了：",
		zhTW = "你製造了："
	},
	["YOU_EARNED_LABEL"] = {
		ruRU = "Вы заслужили:",
		enGB = "You Earned:",
		esMX = "Has ganado:",
		deDE = "Ihr erhaltet:",
		frFR = "Obtenu :",
		itIT = "Hai ottenuto:",
		koKR = "획득:",
		ptBR = "Você ganhou:",
		zhCN = "你获得了：",
		zhTW = "你獲得了："
	},
	["NEW_RECIPE_LEARNED_TITLE"] = {
		ruRU = "Выучен новый рецепт!",
		enGB = "New Recipe Learned!",
		esMX = "¡Nueva receta aprendida!",
		deDE = "Neues Rezept erlernt!",
		frFR = "Nouvelle recette apprise !",
		itIT = "Nuova ricetta appresa!",
		koKR = "새로운 제조법 습득!",
		ptBR = "Nova receita aprendida!",
		zhCN = "学会了新配方！",
		zhTW = "學到了新的配方！"
	},
	["LEGENDARY_ITEM_LOOT_LABEL"] = {
		ruRU = "Легендарный предмет!",
		enGB = "Legendary Item!",
		esMX = "¡Objeto legendario!",
		deDE = "Legendärer Gegenstand!",
		frFR = "Objet légendaire !",
		itIT = "Oggetto leggendario!",
		koKR = "전설 아이템!",
		ptBR = "Item lendário!",
		zhCN = "传说物品！",
		zhTW = "傳說級物品！"
	},
	["TOAST_PROFESSION_COOKING"] = {
		ruRU = "Кулинария",
		enGB = "Cooking",
		esMX = "Cocina",
		deDE = "Kochkunst",
		frFR = "Cuisine",
		itIT = "Cucina",
		koKR = "요리",
		ptBR = "Culinária",
		zhCN = "烹饪",
		zhTW = "烹飪"
	},
	["TOAST_PROFESSION_FIRST_AID"] = {
		ruRU = "Первая помощь",
		enGB = "First Aid",
		esMX = "Primeros auxilios",
		deDE = "Erste Hilfe",
		frFR = "Secourisme",
		itIT = "Primo Soccorso",
		koKR = "응급치료",
		ptBR = "Primeiros Socorros",
		zhCN = "急救",
		zhTW = "急救"
	},
	["TOAST_PROFESSION_FISHING"] = {
		ruRU = "Рыбная ловля",
		enGB = "Fishing",
		esMX = "Pesca",
		deDE = "Angeln",
		frFR = "Pêche",
		itIT = "Pesca",
		koKR = "낚시",
		ptBR = "Pesca",
		zhCN = "钓鱼",
		zhTW = "釣魚"
	},
	["TOAST_PROFESSION_ALCHEMY"] = {
		ruRU = "Алхимия",
		enGB = "Alchemy",
		esMX = "Alquimia",
		deDE = "Alchemie",
		frFR = "Alchimie",
		itIT = "Alchimia",
		koKR = "연금술",
		ptBR = "Alquimia",
		zhCN = "炼金术",
		zhTW = "鍊金術"
	},
	["TOAST_PROFESSION_TAILORING"] = {
		ruRU = "Портняжное дело",
		enGB = "Tailoring",
		esMX = "Sastrería",
		deDE = "Schneiderei",
		frFR = "Couture",
		itIT = "Sartoria",
		koKR = "재봉술",
		ptBR = "Alfaiataria",
		zhCN = "裁缝",
		zhTW = "裁縫"
	},
	["TOAST_PROFESSION_JEWELCRAFTING"] = {
		ruRU = "Ювелирное дело",
		enGB = "Jewelcrafting",
		esMX = "Joyería",
		deDE = "Juwelierskunst",
		frFR = "Joaillerie",
		itIT = "Oreficeria",
		koKR = "보석세공",
		ptBR = "Joalheria",
		zhCN = "珠宝加工",
		zhTW = "珠寶設計"
	},
	["TOAST_PROFESSION_ENCHANTING"] = {
		ruRU = "Наложение чар",
		enGB = "Enchanting",
		esMX = "Encantamiento",
		deDE = "Verzauberkunst",
		frFR = "Enchantement",
		itIT = "Incantamento",
		koKR = "마법부여",
		ptBR = "Encantamento",
		zhCN = "附魔",
		zhTW = "附魔"
	},
	["TOAST_PROFESSION_BLACKSMITHING"] = {
		ruRU = "Кузнечное дело",
		enGB = "Blacksmithing",
		esMX = "Herrería",
		deDE = "Schmiedekunst",
		frFR = "Forge",
		itIT = "Forgiatura",
		koKR = "대장기술",
		ptBR = "Ferraria",
		zhCN = "锻造",
		zhTW = "鍛造"
	},
	["TOAST_PROFESSION_ENGINEERING"] = {
		ruRU = "Инженерное дело",
		enGB = "Engineering",
		esMX = "Ingeniería",
		deDE = "Ingenieurskunst",
		frFR = "Ingénierie",
		itIT = "Ingegneria",
		koKR = "기계공학",
		ptBR = "Engenharia",
		zhCN = "工程学",
		zhTW = "工程學"
	},
	["TOAST_PROFESSION_MINING"] = {
		ruRU = "Горное дело",
		enGB = "Mining",
		esMX = "Minería",
		deDE = "Bergbau",
		frFR = "Minage",
		itIT = "Estrazione",
		koKR = "채광",
		ptBR = "Mineração",
		zhCN = "采矿",
		zhTW = "採礦"
	},
	["TOAST_PROFESSION_LEATHERWORKING"] = {
		ruRU = "Кожевничество",
		enGB = "Leatherworking",
		esMX = "Peletería",
		deDE = "Lederverarbeitung",
		frFR = "Travail du cuir",
		itIT = "Conciatura",
		koKR = "가죽세공",
		ptBR = "Couraria",
		zhCN = "制皮",
		zhTW = "製皮"
	},
	["TOAST_PROFESSION_INSCRIPTION"] = {
		ruRU = "Начертание",
		enGB = "Inscription",
		esMX = "Inscripción",
		deDE = "Inschriftenkunde",
		frFR = "Calligraphie",
		itIT = "Runografia",
		koKR = "주문각인",
		ptBR = "Escrivania",
		zhCN = "铭文",
		zhTW = "銘文學"
	},
	["ITEM_TYPE_RECIPE"] = {
		ruRU = "Рецепт: ",
		enGB = "Recipe: ",
		esMX = "Receta: ",
		deDE = "Rezept: ",
		frFR = "Recette : ",
		itIT = "Recipe: ",
		koKR = "조제법: ",
		ptBR = "Receita: ",
		zhCN = "配方： ",
		zhTW = "配方： "
		-- 食譜 食譜:鮮魚宴
	},
	["ITEM_TYPE_PLANS"] = {
		ruRU = "Чертеж: ",
		enGB = "Plans: ",
		esMX = "Diseño: ",
		deDE = "Pläne: ",
		frFR = "Plans : ",
		itIT = "Plans: ",
		koKR = "도면: ",
		ptBR = "Instruções: ",
		zhCN = "设计图： ",
		zhTW = "設計圖： "
	},
	["ITEM_TYPE_FORMULA"] = {
		ruRU = "Формула: ",
		enGB = "Formula: ",
		esMX = "Fórmula: ",
		deDE = "Formel: ",
		frFR = "Formule : ",
		itIT = "Formula: ",
		koKR = "주문식: ",
		ptBR = "Fórmula: ",
		zhCN = "公式： ",
		zhTW = "公式： "
	},
	["ITEM_TYPE_SCHEMATIC"] = {
		ruRU = "Схема: ",
		enGB = "Schematic: ",
		esMX = "Esquema: ",
		deDE = "Bauplan: ",
		frFR = "Schéma : ",
		itIT = "Schematic: ",
		koKR = "설계도: ",
		ptBR = "Diagrama: ",
		zhCN = "结构图：",
		zhTW = "結構圖："
	},
	["ITEM_TYPE_MANUAL"] = {
		ruRU = "Учебник: ",
		enGB = "Manual: ",
		esMX = "Manual: ",
		deDE = "Handbuch: ",
		frFR = "Manuel : ",
		itIT = "Manual: ",
		koKR = "처방전: ",
		ptBR = "Manual: ",
		zhCN = "手册： ",
		zhTW = "手冊: "
	},
	["ITEM_TYPE_TECHNIQUE"] = {
		ruRU = "Технология: ",
		enGB = "Technique: ",
		esMX = "Técnica: ",
		deDE = "Technik: ",
		frFR = "Technique : ",
		itIT = "Technique: ",
		koKR = "기법: ",
		ptBR = "Técnica: ",
		zhCN = "技巧： ",
		zhTW = "技藝: "
	},
	["ITEM_TYPE_DESIGN"] = {
		ruRU = "Эскиз: ",
		enGB = "Design: ",
		esMX = "Boceto: ",
		deDE = "Vorlage: ",
		frFR = "Dessin : ",
		itIT = "Design: ",
		koKR = "디자인: ",
		ptBR = "Desenho: ",
		zhCN = "图鉴： ",
		zhTW = "設計圖："
	},
	["ITEM_TYPE_PATTERN"] = {
		ruRU = "Выкройка: ",
		enGB = "Pattern: ",
		esMX = "Patrón: ",
		deDE = "Muster: ",
		frFR = "Patron : ",
		itIT = "Pattern: ",
		koKR = "도안: ",
		ptBR = "Molde: ",
		zhCN = "图样： ",
		zhTW = "圖樣:"
	},
	["ITEM_TYPE_MOUNT"] = {
		ruRU = "Верховые животные",
		enGB = "Mount",
		esMX = "Montura",
		deDE = "Reittier",
		frFR = "Monture",
		itIT = "Mount",
		koKR = "탈것",
		ptBR = "Montura",
		zhCN = "坐骑",
		zhTW = "座騎"
	},
	["ITEM_TYPE_MOUNTS"] = {
		ruRU = "Верховые животные",
		enGB = "Mounts",
		esMX = "Monturas",
		deDE = "Reittiere",
		frFR = "Montures",
		itIT = "Mounts",
		koKR = "탈것",
		ptBR = "Monturas",
		zhCN = "坐骑",
		zhTW = "座騎"
	},
};

setmetatable(private.locales,{
	__call = function(self, key)
		if not self[key] then
			return "Locale not found";
		end
		-- struct langstringref;
		if LOCALE == "ruRU" then
			return self[key].ruRU;
		elseif LOCALE == "esMX" or LOCALE == "esES" then
			return self[key].esMX;
		elseif LOCALE == "deDE" then
			return self[key].deDE;
		elseif LOCALE == "frFR" then
			return self[key].frFR;
		elseif LOCALE == "itIT" then
			return self[key].itIT;
		elseif LOCALE == "koKR" then
			return self[key].koKR;
		elseif LOCALE == "ptBR" or LOCALE == "ptPT" then
			return self[key].ptBR;
		elseif LOCALE == "zhCN" then
			return self[key].zhCN;
		elseif LOCALE == "zhTW" then
			return self[key].zhTW;
		else
			return self[key].enGB ~= "" and self[key].enGB or key;
		end
	end
});

for key in next, private.locales do
	_G[key] = private.locales(key);
end