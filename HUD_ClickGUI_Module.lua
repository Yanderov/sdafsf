-- HUD_ClickGUI_Module.lua
-- Reusable Roblox UI-only module. It contains ClickGUI, themes, localization, HUD cards and controls.
-- It deliberately contains no game/role/combat/ESP/teleport logic: feature behavior is supplied by callbacks.

local HUD = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local THEMES = {
    Default = {
        BG=Color3.fromRGB(3,3,3), Sidebar=Color3.fromRGB(4,4,4), Card=Color3.fromRGB(8,8,8), Elev=Color3.fromRGB(13,13,13),
        Hover=Color3.fromRGB(19,19,19), ActiveBg=Color3.fromRGB(26,26,26), Bd=Color3.fromRGB(20,20,20), Bd2=Color3.fromRGB(40,40,40),
        White=Color3.fromRGB(255,255,255), Tx=Color3.fromRGB(238,238,236), Tx2=Color3.fromRGB(214,213,210), Tx3=Color3.fromRGB(180,179,175), Tx4=Color3.fromRGB(154,153,149),
        Accent=Color3.fromRGB(216,215,211), Glow=Color3.fromRGB(145,144,141), TgOff=Color3.fromRGB(29,29,29), TgOn=Color3.fromRGB(176,176,174),
        KnobOff=Color3.fromRGB(137,136,133), KnobOn=Color3.fromRGB(250,249,246), AccentSoft=Color3.fromRGB(72,72,71),
    },
    Graphite = {
        BG=Color3.fromRGB(32,32,32), Sidebar=Color3.fromRGB(38,38,38), Card=Color3.fromRGB(44,44,44), Elev=Color3.fromRGB(52,52,52),
        Hover=Color3.fromRGB(62,62,62), ActiveBg=Color3.fromRGB(74,74,74), Bd=Color3.fromRGB(58,58,58), Bd2=Color3.fromRGB(80,80,80),
        White=Color3.fromRGB(255,255,255), Tx=Color3.fromRGB(238,238,236), Tx2=Color3.fromRGB(214,213,210), Tx3=Color3.fromRGB(180,179,175), Tx4=Color3.fromRGB(154,153,149),
        Accent=Color3.fromRGB(216,215,211), Glow=Color3.fromRGB(145,144,141),
    },
    Ocean = {
        BG=Color3.fromRGB(14,38,65), Sidebar=Color3.fromRGB(18,48,80), Card=Color3.fromRGB(23,58,95), Elev=Color3.fromRGB(30,70,112),
        Hover=Color3.fromRGB(38,84,130), ActiveBg=Color3.fromRGB(48,102,154), Bd=Color3.fromRGB(44,89,132), Bd2=Color3.fromRGB(62,119,172),
        White=Color3.fromRGB(235,249,255), Tx=Color3.fromRGB(212,238,250), Tx2=Color3.fromRGB(174,215,235), Tx3=Color3.fromRGB(132,181,208), Tx4=Color3.fromRGB(102,150,180),
        Accent=Color3.fromRGB(67,190,255), Glow=Color3.fromRGB(32,114,242),
    },
    Forest = {
        BG=Color3.fromRGB(14,45,26), Sidebar=Color3.fromRGB(18,56,32), Card=Color3.fromRGB(23,67,39), Elev=Color3.fromRGB(30,80,47),
        Hover=Color3.fromRGB(38,95,57), ActiveBg=Color3.fromRGB(48,114,69), Bd=Color3.fromRGB(44,101,61), Bd2=Color3.fromRGB(63,132,81),
        White=Color3.fromRGB(240,255,246), Tx=Color3.fromRGB(220,244,230), Tx2=Color3.fromRGB(184,222,199), Tx3=Color3.fromRGB(142,186,159), Tx4=Color3.fromRGB(110,156,128),
        Accent=Color3.fromRGB(69,220,125), Glow=Color3.fromRGB(23,156,82),
    },
    Wine = {
        BG=Color3.fromRGB(58,16,34), Sidebar=Color3.fromRGB(70,20,42), Card=Color3.fromRGB(82,25,50), Elev=Color3.fromRGB(96,32,60),
        Hover=Color3.fromRGB(113,41,72), ActiveBg=Color3.fromRGB(134,52,87), Bd=Color3.fromRGB(106,44,76), Bd2=Color3.fromRGB(142,61,98),
        White=Color3.fromRGB(255,240,248), Tx=Color3.fromRGB(247,215,231), Tx2=Color3.fromRGB(226,175,201), Tx3=Color3.fromRGB(193,132,163), Tx4=Color3.fromRGB(160,102,131),
        Accent=Color3.fromRGB(255,93,169), Glow=Color3.fromRGB(204,39,118),
    },
    Violet = {
        BG=Color3.fromRGB(45,25,72), Sidebar=Color3.fromRGB(55,31,86), Card=Color3.fromRGB(66,38,101), Elev=Color3.fromRGB(79,47,117),
        Hover=Color3.fromRGB(94,58,135), ActiveBg=Color3.fromRGB(113,71,158), Bd=Color3.fromRGB(92,58,132), Bd2=Color3.fromRGB(127,80,171),
        White=Color3.fromRGB(248,241,255), Tx=Color3.fromRGB(232,216,248), Tx2=Color3.fromRGB(202,178,229), Tx3=Color3.fromRGB(169,138,207), Tx4=Color3.fromRGB(137,107,175),
        Accent=Color3.fromRGB(166,104,255), Glow=Color3.fromRGB(108,61,219),
    },
    Ember = {
        BG=Color3.fromRGB(62,23,8), Sidebar=Color3.fromRGB(74,28,10), Card=Color3.fromRGB(86,34,13), Elev=Color3.fromRGB(101,43,17),
        Hover=Color3.fromRGB(118,54,22), ActiveBg=Color3.fromRGB(139,67,29), Bd=Color3.fromRGB(111,56,26), Bd2=Color3.fromRGB(147,73,35),
        White=Color3.fromRGB(255,246,236), Tx=Color3.fromRGB(248,224,204), Tx2=Color3.fromRGB(231,190,159), Tx3=Color3.fromRGB(201,150,113), Tx4=Color3.fromRGB(169,116,83),
        Accent=Color3.fromRGB(255,116,48), Glow=Color3.fromRGB(225,56,25),
    },
    Amber = {
        BG=Color3.fromRGB(61,47,10), Sidebar=Color3.fromRGB(72,56,13), Card=Color3.fromRGB(84,66,17), Elev=Color3.fromRGB(99,79,22),
        Hover=Color3.fromRGB(116,94,29), ActiveBg=Color3.fromRGB(137,114,39), Bd=Color3.fromRGB(109,91,34), Bd2=Color3.fromRGB(145,120,45),
        White=Color3.fromRGB(255,251,231), Tx=Color3.fromRGB(246,233,195), Tx2=Color3.fromRGB(225,205,151), Tx3=Color3.fromRGB(192,167,106), Tx4=Color3.fromRGB(157,133,78),
        Accent=Color3.fromRGB(255,196,57), Glow=Color3.fromRGB(218,143,21),
    },
    Rose = {
        BG=Color3.fromRGB(62,17,31), Sidebar=Color3.fromRGB(74,21,38), Card=Color3.fromRGB(87,27,47), Elev=Color3.fromRGB(102,35,57),
        Hover=Color3.fromRGB(120,46,70), ActiveBg=Color3.fromRGB(141,58,85), Bd=Color3.fromRGB(113,49,74), Bd2=Color3.fromRGB(150,67,96),
        White=Color3.fromRGB(255,239,244), Tx=Color3.fromRGB(248,214,224), Tx2=Color3.fromRGB(231,175,193), Tx3=Color3.fromRGB(201,131,154), Tx4=Color3.fromRGB(168,99,123),
        Accent=Color3.fromRGB(255,91,126), Glow=Color3.fromRGB(224,34,79),
    },
}

local LOCALES = {
    ENG = {
        Settings="Settings", Language="Language", TextSize="Text Size", HUDSize="HUD Size", NotificationPosition="Notification Position",
        NotificationColor="Notification Color", ThemeStyle="Theme Style", Executor="Executor", RoundRoles="ROUND ROLES",
    },
    RU = {
        Visuals="Визуалы", Combat="Бой", Motion="Движение", Player="Игрок", Misc="Разное", Teleport="Телепорт", Servers="Сервера", Config="Конфиг",
        Settings="Настройки", Close="Закрыть", Search="Поиск", NothingFound="Ничего не найдено", Language="Язык", TextSize="Размер текста", HUDSize="Размер HUD",
        NotificationPosition="Позиция уведомлений", NotificationColor="Цвет уведомлений", ThemeStyle="Тема", Executor="Экзекутор", RoundRoles="РОЛИ РАУНДА",
    },
    UK = {
        Visuals="Візуали", Combat="Бій", Motion="Рух", Player="Гравець", Misc="Різне", Teleport="Телепорт", Servers="Сервери", Config="Конфіг",
        Settings="Налаштування", Close="Закрити", Search="Пошук", NothingFound="Нічого не знайдено", Language="Мова", TextSize="Розмір тексту", HUDSize="Розмір HUD",
        NotificationPosition="Позиція сповіщень", NotificationColor="Колір сповіщень", ThemeStyle="Тема", Executor="Екзекутор", RoundRoles="РОЛІ РАУНДУ",
    },
    SPANISH = {
        Visuals="Visuales", Combat="Combate", Motion="Movimiento", Player="Jugador", Misc="Varios", Teleport="Teletransporte", Servers="Servidores", Config="Config",
        Settings="Ajustes", Close="Cerrar", Search="Buscar", NothingFound="Nada encontrado", Language="Idioma", TextSize="Tamaño del texto", HUDSize="Tamaño del HUD",
        NotificationPosition="Posición de avisos", NotificationColor="Color de avisos", ThemeStyle="Tema", Executor="Ejecutor", RoundRoles="ROLES DE RONDA",
    },
}

local NOTIFICATION_COLORS = {
    Theme = false,
    White = Color3.fromRGB(244,244,240),
    Green = Color3.fromRGB(88,220,132),
    Yellow = Color3.fromRGB(255,202,72),
    Red = Color3.fromRGB(255,78,78),
    Pink = Color3.fromRGB(255,104,173),
}

-- Lucide navigation icons (ISC): https://github.com/lucide-icons/lucide
local NAV_ICON_DATA = {
    ["eye"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAC+klEQVRoge2YwU8TQRTGvwWCxEQu9VLTyAkPeCF6ABKTEjnI34EHCByoV2uix14ketMLfwFq8A9ADAcBb8iJg6AmkBAhJBATG9Kfh50mzXS2O20XEN0v2bTbfd/33kxn3r55UooUKVKk+J8RJCECXJU0LOme+bwhKSPpujH5KelA0q6kVUkrktaCIPiVhP+WAHQC48AboEzzKBvuONB5noF3AVPAtxaCjsKO0ew66+DHgC8JBm5jAxhrJiavPQBckfRS0mSESUXh2v4kaU3SlsI1f2CeZ8x1S9KQpBGFe6UjQu+1pNkgCH77xBcXfB/wOWLGtoHHQK4F3ZzhbkdorwM32w3+NrDvED8EZoHuthyEPrqN1qHDzz4w0KpwP7DnEF0EMu0G7vCXMdo29oD+ZsVywA9LqGL+8qh1W+VmgRKwSZgqy+Z7CcjGcDuMj4rl+zu+y5Qwv390zMREDC8AZoATB7eKE2PTMHkAEw7uMj7vC+CJg1zwCH6uQeA25jwG8cjBK8YFPwicWqR5j0HPNBF8FdMeuvMW5xQYbER4bxG+AtdinGSpXzZrQB7oMVfe/FaLY+L3RC/1aXYxyviuY5bue8xSyRF83Vol3Fv2IEoe+mOOuO64DN9ZRh/ixA1v0+LlG9jmLdtNTx/LFu+ty+jIMhr1FLcr0Z4Gtj2WbdnTx6jFO6o+a5jTLwNqB2AvmaeeGlvW/VADW/uZzY3CM+t+qc6Cy76JjbErjfbGOPg70qghXO4XmSGdRynxnLMoJQyxnWJumnBpROHY2MQF/9DB9SvmjECOsIStRQUocvbldJF2yukasYs40NhJBGCXZg80NaIDRB8pCyR3pCyQ9JGyxkEf4QHbhW3zl7d6qC/S5qG+mbbKC0lTESbVtsqq/NoqwwpbK1H+X0kqJNJWqQXhW3EjYsaSwAYeb/92B1FtLe4kGPgOMMk590g7gQfAAq03dxeMRstVcZLt9SGF7fURSVm52+t7CtuPK5LWL7S9niJFihQp/gn8AXDP9oufq13tAAAAAElFTkSuQmCC",
    ["crosshair"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAADC0lEQVRoge2asU4bQRCGZ1NHsmiSgspIRlCE4BeAIsg1ooMOpeJVQrpQQEpcQIVS8AJ5AqSk4ApIGihMAZGgASG+FLe213Nre+98Z/sk/sq+nX/2n7u93dmdE3nFZGHycAIYEVkSkXURqYvIgojMishba/IgItciEonImYj8EJFfxhjy6D8zgDqwC1ySHpeWW5+E8CpwnEF0PxwD1XEIrwBfgcccxbfxaH1XihI/D0QDBFwB+8AmsOJpX7Ft+9a2HyKglrf4NeDO09kT8A1YJn6RXU4PVJuxnD3rQ+MWWMtL/DbwrDp4AQ4ZMG4HBaDsqtbXi6I8A9ujil/ziL8DGgHcoAAc+wbJp/wMfMoqvuZxGAHzgfxUAViO7z27Je07QTzbaEcRMJPCR+oALG+mT9/hsxPxdObiLvTOOz5aDr+VkjsP/FMadkPJc/TO8y8EjHmPnw0bRAvYyMBv0PtiPxKy2JFcYQ/Tdp4XgKbScjSMUFeEp6CoC4IdDXqd6Mmd3ijOlvp/YIz5W6zM/jDG/BGR7+rypteYeHXUWeVy4SqHwDMqLlCrftvwozK88hqOGfbGXittS+12dwitK+7pxDccImI1nKrLHa1uAHpj8bMoURmgtXS0ugEsKKPrwuSkh9aymLAA7glDpoVpGOgufCG4b/OM4yDNeL8xxrzPOYCWiLwLtTfGGJHkOlA6uAE8BHJuRGSnAC071ncIklpJprArucobAcCq0ha129wnECne7HjkBUFrOW//cAM4U0arhclJD61Fay1vKqENS5fMdYaQzTlOFP/zuIQOgNZw0jdH80Q79RsaH6m8W0pLqlLmTb0ll/dYxToo98GWdVQjPtbTjqb/aNFxOO7DXT1ssh/uOo77Ha83gblRAyCeKpsUcbzudDKowLFHvH6kLXDUGVzgGO3Oe4KoMbzEdABskUx/sde2rI3ObVzkX2JygqgQl0aLKvLtUlSRTwVSBY5yFH/EJFIW4nH8hWyF7gvLHanQneenBh+k+6nBovg/NTiX7qcGv6fh5O8Vo+I/UeCznCCfR4oAAAAASUVORK5CYII=",
    ["gauge"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAC0UlEQVRoge2YO2wTQRRF30ZyA1WKgEiiSEGKQCAiFCdKlSJpcBUpjatItFBSRuLT86ncuAGJXwFJGsA0/BooAFNF0EVJAYWdQIkUJPtQeCyG5xln197dpNgrrWR577vvzHp2Zz0imTJlynSQCuIKAsZFZF5EpkXkuIgcM4eISN0cNRGpisi7IAi24urds4CzQBnYJrq2Te2ZtKEDYB6o9ADtU8VkxjYjfPBDwHoEsF1zhNUaMJQU/CJQ69J8A7gDFIARIGfV5sx3BePZ6JJTAxbjhr/hadYAngBTPWTmTW3Tk309LvhrngavgYkY8idMlktX+w1fcYTuAVeAgX7hrT4DJnPP0W+l19CCI+wXMBMXuKPnjOmhdSFq0CDwwwEfea5HFTDlGMR3YDBKyEMV8BvIJ8it++dNT1sPwhbPOn7CSwkzuzguOzhmwxSuqqJnJLBCAkWgbo4lx/kAeK5Ynu4XOk7r2d7WH2A0Afhl1afu8Y0ahrYatF4avcG31YjvpgDvHYDx31PeW93Cv1nGJnAqBfgGUOxSc5r/V+uvPuOICv6cEvxyiNqqqhtun7NX0wVV9ypOeBG5r/o1ReRiEASPQkRoFs0qApTUKDtNPaifK29lLKj6ksu0pkwnDgO8yRlWGasu0wdlyjmyojQtxgFvsnIq573LtGkZfvYDb/LqccBbefb70Wb7e/umslfbvq6+Q1FuWJ+6MwGf1BU70kczAZb496rgfc6HzDqq2D66TC+Vyb9kpyzgpGKrtM/ZU2hH1Z1PBy+UNMtu+4M9gC/KFO1fULLSLNUOBzCpfqYtkt5oCiFar9V65++cyzhA5ybU3AEwa645xbSDb0MBeKzML1LmdTHpLUz/o5jWroDWZIq8mkdPa4Dp/YreqoJySrwulrJieaM9rrl0MwW2XrU/G627vkRrl6wKjKUA5mMZMwx7hunAn4qZMmXKlOlw6S+/znsQLzCvmQAAAABJRU5ErkJggg==",
    ["user-round"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAACtklEQVRoge2YP2/TQBjGX6NmKZHo1KUZTLsgkZ1/G5WCBBISYSISTPQDwAwfofxZygQrHQCJwhiVmU9AWLJVIplQCCURlX4MOUvuGzuxz2e7FXkkS3mdu+d53vPd6/OJLLDA/w3PJRmwIiK3RaQpIhdEZM38dSAiHRH5ICJ7nuf9dKmbGcAy8BQYMh9D03a5bN8iIgLUgW4C4xpdoF62+U1gYGE+wADYLMt8PcZ8G7gH+EDFXL65145JotgnwWTO62nTBxoJ+jZM2zC6FLkmmCzCMHqAn6K/H5HEkxwtHxNfYbrazB35CJ6G4hgC5/LwrIUfKOF2Bi69Ju6n5ThjodtU8WsLjgBvVHw3A1cyAB01an4GLl9xfXNoNVb0lxKtZOCqKK5BWg6bKXSiYJPAgYrXIlslg+6ruefCJoGOiq9YcAS4quLvGbiS4aSVURtRVy+yG4qjmBeZEddbiX6ackqZWwlj4HRv5oyRWdvpFtPb6Rbx2+mLhZoPJeHig+Z6KeZDSbRI9i2sMQRaZRpfB3YzjH6AXWC9aPNbwNiB+QBjYKsI40vAyxgTR8A+8Ai4BmwAVXNtmHuPTZujGI4XwFKe5vciREfANrCagmvV9BlF8H3MJQkzOhpfgFoGzprh0Hju0nsw5zV2yPAtEOKuAK8i+B+68B5UG71gd5yQH9fRSYyB8y6IdancdzHyETqViOn0NivpZUU4IsOcT6BXY3phX8pC+F6RbTv0G6f5TGm+syU6CxyGiP6SolTagkmJDb8nfmOzUwWaeu7n4DdOW6+FO3FtZ30T31TxZzf2EuGTim/FNZyVgC5hX63tpIfW8uMazkpAH3n8sHVjgZ6K0x/dMH0CV3XjLZF2VWnHntjNegKHod99z/OG7izOhtHqh279SU1iqlDPXPpEOneUrb/AAqcF/wBeUYgm6DTGZQAAAABJRU5ErkJggg==",
    ["bot"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAABaElEQVRoge2YMVLDMBBFJUqTGi4FKXIL7gA9ZyA5DZOOk9gXyCTNo8CBjbBlWbIiG/Z1nlnv/9+xpayMURRFWSTABqgZpgY2pf3+ItD8d4hcPm5yNXa4y9U4JcCTMaaZykgsNldjgAsha7NoXesVyoYGKE1QAOAReAcOoetmR49QDq3WQ3I6oAJ2I8SnZgdUKQG2Bc2feYs1vy7tXLCOCbB3mrwCq6inMU531WpJ9jGNjk6T7OaF9srRPvbV9u6OcJ2dNFX/f+wDc0YD8DOZBU1eY+tTjF3gqZOT2eDkFVofqi9v8M64UwnF9pWh5S9nxQ218Yx+fcuYa2JouQ2tH3gYjbX23pg/9hHPYsYNoDFfXv2MeFfn8REnBMiyjIbq63+h0miA0vgCnOQFcJvZi9Ryh6dTZ6HxB/hwrl86Gk9Oq/E84CWo0bKH+jbEco9V2gAVZUNsSTnYEkFGHy0mMN3RoqIoSnY+AasNL0wvBWq1AAAAAElFTkSuQmCC",
    ["wrench"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAC8ElEQVRoge2YQUgUURjH/yNSEERFhBSBKGkIRUEXkY5SkAVCZYLHBK+Bh64ldAvqEhRBUGR0C6JbBoJSFlFdhBLyVEknEy2SXH8d5m1Mn29mR93dmYX9wx5mvv+87/fevLfveyPVla2CaiYDOiT1SDouqV3SPhdalDQjaUrS9SAI5qvJlSggAHqBV6TTF2BP1tySJKAFmEgJHtVI1uwCTgI/SoAWYu6Pp83TUCH4HklPJe0woRVJ9ySdltQmaaukIU8T3yrBlUpAG7DkGdVRoNl4+z1voQAczQq+AZjywF8BAuONg+/PBN5B9Xnghz2+/ME7sA8GamyzIw8cAR4B48AIlfqLBQ4ZqJ9Ai/F0rhPe19mvwK5KdOCySXTf45ncJHxR1yrRgScmyXkTbzRAG4UHGCt6y7kPtJvr5yX83tyuU6NxcaeD6+BKJ2AuMkILMZ7EKRQz8gVgyNwrf7EHfI8kWIzxxC7iBPh+1k6/inTgo0m+P8YXB2r17+0AB0xsutheOdfArLnu8ZmCIHgsaUDSauS25ViVNOC80to5PxP34Gb01lyfiTPGdKIoCy9JZ41nckOESQJumtf8G9hS4plOwoVdcL9JoNN4moE/pu2OcsP75vUC0Jjy+Uafl/A0N2ranaoGfAG4UIa2r3oWd285uIsJKlJVupEf9sBPYIrDqsG7aZK4JpyvFXjhgZ/HFIfVhO8jXBNFDQJ7I/GdzvOAsIq1WgZOZAWfVJgtupFN0hJwKo/wafQGsEViTcC/J5xSJTfaVCsaf4nr2zFL+W9JWpJ0TFKrws8uK5LmJX2S9FrSsyAIplUulWnkszmw1+Hr8BtQrcN31zL8NmC2JuEd0KWahXdQDw3QYIwvf/AO7F0EaA5P3Z1beAc3FoFaBppMPL/wkgTcMHAvgSbC09HFXMNLEtDFWi3z/yfDfMIXBdzxwNYGvCQB24HbCfCfge6sOaPyngeALknnJB2WtFvStMIvb3eDIPhVPby68q+/skEi4gAI/58AAAAASUVORK5CYII=",
    ["settings-2"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAABSUlEQVRoge2XMW7CQBBF/wYlIhdIxElS+g7cAnIRmnCv9K5yA2hBSkSKR+ENMit7HVuAd9E8yYXX3/Ifa8eeLxmGYWQBMANWQAkc/FH6tdnY/loBHPAO7Gln7zVubL9nePPriPGQdVJF+Lfal+XYviWd9ny4bT6BApj6o/BrdXak0BNUzRmanzToJg1FrMbwHBorA1NFRFv03Wf/YAPMu3y2NhxwkPRYW3p2zv20aKeSvrseNoCtc+41Jni4wkNvSqyAr+D8LaKNXRvKVtJi8N3cQRPn/RmVMv+RSYNGiQ9SGiWkUxFLvzXa2HlNWubrkOs4bRjGdcj2o4Bl7BEh59GE3IdDxhrPgTlVPr00fTJ22abtbBBgI+llYP0x+mTsX+fcU5P2rjPxHwtV+fTS9MnYYT6/PVjGTgBy/pFJlrHTglzHacMwjDOOf1ZhXlVHNr4AAAAASUVORK5CYII=",
    ["search-check"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAADEElEQVRoge2ZO09UQRiGvyHQAPVqIiZy+Q9rwg8wgQoLkEukgc5G/R2gNlATNRCDBV6IFrK1v0A7aCjcUsNmicBjceYkh29n9lx2zgph32SK2Z153/ebM2cu3xHpoYebDdMpATAkIg9EZEpERkXkji0iIse2HIrIvoh8McY0OtUMAqAKvAcaZEfD9qn+T+NjwE4O0z7sAGPdNr8KnAYwH+MUWO2G8X7glcfEGXAAPAUmgXFg2JZx+9sz2+bMw/ES6C/T/AeHaBNYAyo5uCq2T9PBt1dKEHZ0NGrASAecI5ZD40VI7/Gc19gABgJwDwCbDv6VEN7j1Ua/sBtByC/r6CBOgdEQxHqpPAgx8g6dAcd02u6U9L4ibNLBnM+gN0Lri118syPaLZNYC+jXp7muNHeLEg1x+XjwlxxLZRveWaBuy4zj/wqX94kTYLCI0EM99wOYXwLOE5x1Tzv9LrQEqtHn+G1K1T8VMZ0wtSQiWx4tjY+qPp3WwUWql7DvGYSd8Ji/EJEnni5a614R0Z/qMY572s0k5vSsy7yaNtj6UhvtCdX+R5EA/iiSYU+7us9YEfO237Dq8zvNb6jDU5+IbAFx3TVtlo0xbwLp+ZFjCs06RtmF1JFPcOaeQq6X+FjVb7s6GmPeiciyRKPrQ96Rv5XipQWuAA5V3bulW2O+IIpMG611lKNvBApsZI6XNvO0UTw1pZ26kblI9FHijAxHCWAO+GXLXAHdMEcJS3Z9D3OWrKrIyj5O3yXkcdqS6gtNjetyobHEpV8pAQN8UxphrpRWwHWp3wzxJOzIa/MQ6lKfEOpmWuUCeBTSf5zY2nOINYlWjryJrXXcia0Y58B8GUG4ngREa3eNKH04SXSeiVOLE/a357aNL7V4UXoQNpAykrsrwDzu4/dCGUGMAtsBzG+TWG2Aha4FYQWrwC7Rlp8VJ7aPc5NqE8Siz0eIT0yDEn1impboDuv6xHQkIp9F5GvaJyY74q+l9UL02BjztlO/XQGw6HkSLXfvKwtPEM580pUFGRNiVxqkpCR76OGm4x9F0gpf3g8C9gAAAABJRU5ErkJggg==",
    ["ghost"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAACW0lEQVRoge2YvW7UQBSF76BsQ0KbJluQ5CGCxAMghYqVUJpFNOQB4AV4ggRoQk1FCij4EaIKNU9BhYRpkCCsdkXYL8XOSvZlxju2xx4h+UiW1vaZc+6xrsczK9IjLUwsIWBdRG6JyL6IbIvIlj1ERL7a44uIfBCRj8aYSSzvRgD2gNfAhHBM7Ji9lIXvAKcVivbhFNjpuvhDYBah+CVmwGEXha8BzzxFXABnwEPgJrALbNhj1157ZDkXHo2nwFqbxb91mE6BI2CzgtamHTN16L1pJYR9OhqfgGEDzaHV0HgSs/Zlz2ucAIMI2gPguUP/QYzal7ONfmFPoogXfXSIGbAdQ1hPlWcxnrzDZ+Bop5dNRW8owSkNej7Ab8i/L3b9jx2Lr2UeRxHr9XkeK89XdYXWKS4P/lBhqqwLFlNs/jvxG7haR2ike7+Fen3e+l244+NeKdHZV+fv45QXhHfq/LaPWBZAT2Gfa5dTHdrruo9YFmBLnX9zkWyrZcB34O6qygL52YpaVgP4pfpww8PLcpwfQNlDCeKzWADm8dOnV2ZWKNgYc15WWEw4vK5VFlFPgBJeGy0U7O/dE+tBxpho++cQhPqX9uv/gD5AavQBUqMPkBp9gNToA6RGHyA1KgcADuxyOAMed8WrDNd6HBgDf9WtsWNsY17ofiA4gMcMe22cGxeFFxogeEMjInPxt9xcRO7b3y8i8Qr3fBuaKgGSIuaObC4i9+wx75BXDY7ebK3fA3hRXuKCWYlpbF7tANkqsxw3P5cfRODpEPqfuqAAoxCztqDCjrr27xGKS3Ij99QOg5VTAAAAAElFTkSuQmCC",
    ["workflow"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAABQElEQVRoge2YPbLCMAyEZSpShHuRQ3EB+vc4Dy3HoQjdUmAYY/JnBVliRl+XjKXszjiONkSO44wCoANwBtBjnj6u7bR1E4AGwGmB6DH+ATSaBtaIf5nQEt99QfyT+tsJj32ccgTQLqhr49qUcw3NuZD8hZ0Vn9S2WW0vqZWIKAyIwNuCED7WTLG2vpSNZPMauAFt3IA2bkCbIQO39KL0QzbVS4IhA5fs+rB0lCCiw0wvefDdYW5f3UA08bvjdDTQ4BFKuPxBM9AkRjiRUmfbLCVXXVirn7E5BmApYzMN2DkUSg3AWsZmGLCVsRkGRDN2cV6NTbbJrV0I4TqxXjRjc6ZR1qxkBqx8KRnPW1U/1pR9LFoxwJ6VTBhImpeMBiIGRP+aPQW8PdDAKWSKGgZEM3YNA56xEzxjcw14xnYcZ5g7XVGu8/zX9zgAAAAASUVORK5CYII=",
    ["scan-eye"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAACsElEQVRoge2Zz2oUQRDGa8TLRvcSFKK+QPYS/HORqJAoKK6XkCcwGh9CD3kBbxsweQkNmJPejB4ke8lLGIgR1E1gAwn5eZgK6e3tmenZ6f2H88HCzkzVV18ttTXV3SIlSpRIBFAHtoA23dgDFgPEWFQuG22NXe+FtAKsO0i7kgiQgEu8jTWgkofUR/wgEwBY8yWs+4qnvyXkQnY5EdedibdAtajQvACqGtvElo+j/YcduHhDS9XS0rZtIocTHQZR1GUzSGTpuTBYOeFxMRSRltpjEXkgIndF5LqIXNHHv0RkV0S+i8hXEfkcRdFBqNi2kA542NeI2+6BZydBbdeBWmg9dl9O7PPAJLAKnOQQbuNEOSaL6jEdzvpyYp8H7gG7BYTb+AHM9qonF4Bl4DhByDbwGpgDbhCPJBX9PqfPthN8j4GXhQVmiH+REPwjMJODZ0Z9XFjql/hnwKkV7C+wUIBzQTlMnNLLBJoR6BqwbwXaA6YDcE/TPQv9BKZCaD8L8sEKcAjcTLG/RNxdWvppABMp9reU08T7UOLvOOp0OUP8jsNnJyOJVw6f2yES2LBIvwCJ85H+8klYTfGLlNvERogE/likDzPsWykJtDJ8H1n2v7P0jf0wl4nAJdRI8etbCY33n1jJ87bRCeLWOfw2qgGmiF8uJsbnRaaBxneUMAIuOeoUYJP8w9xmAtfzvog3gqeN003gDTBP9zg9r8+aCb5hxmn8FjSzxIuQUAi3oCHfkrJB8SVlg8BLyg542NeIN1/zLOpb6lN4UR9sYwu4LCJPROS+nG+rXNXH+3K+rfJNRD5FUXToyZuqp9yZGzZcCRyZFwx5c9e6dWTbuBJoWtcrw0hCY65Yt21tTsdRPuB46ks6vkdMSloh7tOjksA78hzyGeSjcMzqVzYlSvyn+AemqJB9pScXYgAAAABJRU5ErkJggg==",
    ["footprints"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAD5klEQVRoge2Yu29cRRTGvzGvGNgYCUEAIx5FOkMDEsYBFCEgJA1EiIY/gVDwEG0qWgoKCBiQUiNAbihSIeKYxgaEQgMSoYp4RMiRhTDEsX8Ud9ea/XbuzL3GuwtSvmrP3O+cOWde38xKV/A/AjAHnASWgVXgIrACvA5MjTu/WgD7gSXyOAfMjDvXAQCHuyPdBOeBW8ed8zaAWeDvhsn3MD/uvCVJwL7uiMa4BLwHPABcB9wIHAM2I84f/Bf2A/CBJX8BOFDDnTfui6PO1xOasVG9DDya4R+yAhZGmW8qoQ8tobcK/GnjfzOqXFPJXA+sRclsAHcUfCatgIsF/hSVdqxQnXCrVNpyEpj7twUctWRONfC5wXzWM9wZKs3IYQnY3yTfiUSbb9TPGsTxs3+1Jvl9kk5JurcQb07SMnC41HGqgIfMbrKefbQu1PDekJRdjhGmJC0Ank8fUgXcbfYPDTp72OyzTqDShheipi1JL0nqSNoj6UFJ85I2Is61kj6ljbpTiVWMqxv4nDGf1xKcY8ZJKjZwgEpzYrzfpoB1c+4U+H6EAtyX4C0Y56lMzMfo16FNai6KqSX0u9nTuQIkPWf2OUnfJXj3mJ3iSJJCCKclvR01TUh6uZBHBeBbG6knCvxF479Zw/Mb7WQh7jSVBvWwlvJJzYCfIL5B405u1+CxW3eN2NOg722EEM5L+jxq6kg65LxUkK/MHnCK8IykENm/SfqyhuvacEsmbg+uQQOXyVQBX5g9S/31+KjZH4cQNmu4PrNNlNY1aNYJqQLOSLoc2VdJOugk4CZJj1vzR5lkXBtql2aE782+ywkDBYQQ1iQtWnNqIz8tKdaIX1QVX4evzX4yw+3BT8TbGvhIwKuJs72E7FMSuN/4W5RvuXvN50/n1J0EK40q7YfPmuOspJ8iO2hQQxyuQT4jtQX8WAicgi+RPoQQ0OAR+3wh5p1mNy7g50Lgnfp4AY8AuXXtG33glpssIISwlWjrQ8It+wrrYkmVVmyHVaUldXANco3Kq2EbpIpOcDYlfWLNriWStq/f/hZwjaqHHzFtv2fiHjTXSymhBJ413gaw13m7NgMtsCjp18i+RpWmOFx7Frsa1Qxk3gVAx77VPuJrYvsfYU3wSipWbgaWzT7eTbwj6XiBW0JOsevQTpuAIy1Gp/jvgcWe2cEMNP0zoK+jdxsEPrGDuDfvoIDU0V3saBI4kQn6DoWXVU3cCQ+U4GS/t+3wCHCaamOvd3+3WjZtE2xaQPtp2SV4Uq7upe89jEMHdhXjLOCv2MB0JseNMc4ChqkzwwdD1JmRgSHpzMjAkHRm5GAIOnMFo8I/gRRKTmfTyMsAAAAASUVORK5CYII=",
    ["map-pin"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAADzUlEQVRoge2ZuWsVURTGzzMLIQkICmI0TRJRglopRkyRRnFBcSlU0FIt4ob+AdooBCEujTZWLtFCCxdERGMnWGiaB4oBRUHraBZeFvlZzJ0wOXPvfXnz7str/GCKO/Od73xn3p27PZH/qC5yoYSAJhHZLiK7RKRNRFaaS0Tkp7m+icgLEXmZy+UmQuUuC0AX8BiYYP6YMDFd1TTeDjwswbQLD4H2hTZ/HJgMYD7GJHB8IYzXAjccJmaAQeAc0A10AM3m6jD3zhvOjEPjOlBbSfNPLUkLQD+wrAStZSamYNF7UpEizNvReAu0lqHZajQ0roX0Hvd5jZtAXQDtOuCWRf9YCO/xaKM/2JtBxOfm0UVMAm0hhPVQORjizVvy1Fm604NyRTcrwQJF+jzQAvQBeWDKXHlzr6VIbCvpDzv7ZEc0WybR7+HmgJPAGG6MGY5zCQNcVTGPsppvYu7yYBrHUGnM68Q+XHUVQTTEJueJcaAxSwEHVNJBD/dkCeZj9Hr03iru/iwF3FYi5x28FtLd5j3QAzSYq8fcS2IUxzdBNGMncTtLAW+USLeD12cxX2Ph1ViK6HNodive6ywFfFYiHQ5eXvF6PJo9ipt38FYp3qcsBYwqkWYHb0rxGjyaDYo75eA1K94fl+YiTw31ql3wcEND59JeZuErYES1XavNL6rtm3j0Mx3ryqW9zMJXwHfVXufgPVftKzg+YhG5UiQ2xvoiXmbhK2BItTc7eDdEZDzR3iQi71DDqIi8M89ijJlYG3Qu7aU4gIN6JMA9ewabyIhm9U+KezBLAY2kJ6gNnqSlLCX6PS9jo+KOkmUpYcTuKzHXTx4X0Ut6+NVmel3mjY7ec9/LZN6I7VFiY8DyIjHlLKeXk/7Vd5dTQB0wrASD78YS+fSubJhyN0/AYSU6A6wO5DmZZw3p45ZDIYQXAUNK+BXgG4Kz5HilcgwFywHsJI0zQcQj/bMW/Z2h9OMkenNfANYG0F1Heh9c3mbekWgp8EslygOLy9BcTHo5/gtYEtJ7MqGtK70GnKtFj1Y90RGNxo5KeE8mth0x3sEzOVk0csBdi871SnqPk9cCzyzJL5WgcdkS/xTLKrYiINoxfbSYODGP2BOWuA84dnwVA7AC+KGMzAB7PTH7gL8q5gdFlhgVA7Ae+G0p4oiFe5T0TPsbcG2UFgbANqJTO41TCc5py/NpYGs1vc8COGLpGgAXgIuW+9ZfqaoA9jO/P/4myXJUuBAw3WncY34c2FZtn14QHQuOWMyPAFuq7W9eADqBAeCruQaAzmr7+o9K4B/zGryOBIgdTQAAAABJRU5ErkJggg==",
    ["panels-top-left"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAAA8klEQVRoge2ZQQ6DIBREsenOy9XzuPcYchp3vZBupgvbhP5iUKMMpvN2mk+cFz6SgHNCiEUANAAGACPyM76/3ewJXgPwhNBLeAD1FgHPzRul39I2pZJuJ8x9F9Jhy/QdBOY27kyWYc1Au2Czhw+y1CbLaGuqyCB8FVTVT01OUnlueeMcjwTYSIDNPVVg/wKlcfkZkACb5BpI7cRn79ypNXj5GZAAGwmwkQAbCbCRABsJsJEAGwmwiQlM4QP7cNe8mmxNTOBpnlvW8bpzrjWvbbbowJIvOB5r7T07aYR1V0yf6QPQsxMH9NjTxrjqNasQf8QLDxQVmh4AoMEAAAAASUVORK5CYII=",
    ["server"] = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAACXBIWXMAAA9hAAAPYQGoP6dpAAABQUlEQVRoge2YMU7DQBBFZ+hS5GCYDokrIHGJXIAeh4MAfVpOklBQmopHYTsaltgyJPYO8bxydy290Y7X3i8SOAQogA1QkZ+K2qUYIr4A1nl9eymBRV8BnuVbSuustm1E5OmIzpuSK1V9/jZC3WeWe2CZSdB6LRsXy+bQwvSFzS7f0hRhqdo520LYh1RVxRFdfhd5dE7H4AKAa2AL7ICbMaX+RHpWHZjfmul3YNLd6/KbTwuJyJ2I7ETkTURuVfVzHKXfEadQbmwBH3bC24csGdq72gJek0UrD0U0DqtkeO/6X3/mClV9ETE70PzdPWZTGs66lf8B9YWmTD8ajnig70JjCvF4pbw89VYGwdmCz5c4ciEvRC40KUQu5IQuv7O6kfVC5ELj+M2nhSRyoeOYxSkUudAYELmQPyIXmprIhVzzBcBOvtLWHDOPAAAAAElFTkSuQmCC",
}
local NAV_ICON_ALIASES = {
    visuals="eye", combat="crosshair", motion="gauge", movement="footprints", player="user-round",
    auto="bot", automation="workflow", misc="wrench", config="settings-2", evidence="search-check",
    ["ghost & hunt"]="ghost", esp="scan-eye", teleport="map-pin", hud="panels-top-left", servers="server",
}
local NAV_ICON_CACHE = {}

local function decodeNavIcon(data)
    local env = (getgenv and getgenv()) or _G
    local cryptApi = env and env.crypt
    local decoder
    if type(cryptApi) == "table" then
        if type(cryptApi.base64) == "table" then decoder = cryptApi.base64.decode end
        if type(decoder) ~= "function" then decoder = cryptApi.base64decode end
    end
    local synApi = env and env.syn
    if type(decoder) ~= "function" and type(synApi) == "table" and type(synApi.crypt) == "table"
        and type(synApi.crypt.base64) == "table" then
        decoder = synApi.crypt.base64.decode
    end
    if type(decoder) ~= "function" and env then decoder = env.base64_decode end
    if type(decoder) == "function" then
        local ok, decoded = pcall(decoder, data)
        if ok and type(decoded) == "string" then return decoded end
    end

    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local lookup = {}
    for index = 1, #alphabet do lookup[string.byte(alphabet, index)] = index - 1 end
    local output = {}
    for index = 1, #data, 4 do
        local a = lookup[string.byte(data, index)] or 0
        local b = lookup[string.byte(data, index + 1)] or 0
        local cByte, dByte = string.byte(data, index + 2), string.byte(data, index + 3)
        local c, d = lookup[cByte] or 0, lookup[dByte] or 0
        local packed = a * 262144 + b * 4096 + c * 64 + d
        output[#output + 1] = string.char(math.floor(packed / 65536) % 256)
        if cByte and cByte ~= 61 then output[#output + 1] = string.char(math.floor(packed / 256) % 256) end
        if dByte and dByte ~= 61 then output[#output + 1] = string.char(packed % 256) end
    end
    return table.concat(output)
end

local function resolveNavIconAsset(kind)
    local data = NAV_ICON_DATA[kind]
    local getter = getcustomasset or getsynasset
    if not data or type(getter) ~= "function" or type(writefile) ~= "function" then return nil end
    local path = "InertiaAssets/lucide48_" .. string.gsub(kind, "%-", "_") .. ".png"
    local exists = false
    if type(isfile) == "function" then
        local ok, result = pcall(isfile, path)
        exists = ok and result == true
    end
    if not exists then
        pcall(function()
            if type(makefolder) == "function" and (type(isfolder) ~= "function" or not isfolder("InertiaAssets")) then
                makefolder("InertiaAssets")
            end
        end)
        local ok = pcall(writefile, path, decodeNavIcon(data))
        if not ok then return nil end
    end
    local asset = NAV_ICON_CACHE[kind]
    if not asset then
        local ok, result = pcall(getter, path)
        if not ok or type(result) ~= "string" then return nil end
        asset = result
        NAV_ICON_CACHE[kind] = asset
    end
    return asset
end


local function corner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = instance
    return c
end

local function stroke(instance, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = 1
    s.Transparency = transparency or 0.35
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = instance
    return s
end

local function gradient(instance, name, first, second, rotation)
    local g = Instance.new("UIGradient")
    g.Name = name or "UIGradient"
    g.Color = ColorSequence.new(first, second)
    g.Rotation = rotation or 90
    g.Parent = instance
    return g
end

local function shadow(instance, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = 2
    s.Transparency = transparency or 0.76
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = instance
    return s
end

local function pad(instance, left, right, top, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.Parent = instance
    return p
end

local function newText(parent, text, size, color, font)
    local label = Instance.new("TextLabel")
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextSize = size or 13
    label.TextColor3 = color
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

function HUD.new(options)
    options = options or {}
    local player = Players.LocalPlayer
    local parent = options.Parent or (player and player:FindFirstChildOfClass("PlayerGui"))
    assert(parent, "HUD_ClickGUI_Module: PlayerGui is not available")

    local palette = {}
    local themeName = options.Theme or "Default"
    local language = options.Language or "ENG"
    local textScale = options.TextScale or 1
    local hudScale = math.clamp(tonumber(options.HUDScale) or 1, 0.8, 1.3)
    local notificationPosition = options.NotificationPosition or "Bottom Right"
    local notificationColor = NOTIFICATION_COLORS[options.NotificationColor] ~= nil and options.NotificationColor or "Theme"
    local controls = {}
    local pages = {}
    local huds = {}
    local localized = {}
    local connections = {}
    local notifications = {}
    local notificationOrder = 0
    local root
    local activePage
    local showPage
    local api = {}

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end

    local function emitSetting(name, value)
        if options.OnSettingsChanged then pcall(options.OnSettingsChanged, name, value) end
    end

    local function translate(key)
        local lang = LOCALES[language] or LOCALES.ENG
        return lang[key] or key
    end

    local function registerText(obj, key, uppercase)
        local item = { Object=obj, Key=key, Uppercase=uppercase == true }
        table.insert(localized, item)
        pcall(function() obj:SetAttribute("LocalizationKey", key) end)
        local value = translate(key)
        obj.Text = item.Uppercase and string.upper(value) or value
    end

    local function applyTextScale()
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local original = obj:GetAttribute("HUDOriginalTextSize")
                if not original then
                    original = obj.TextSize
                    pcall(function() obj:SetAttribute("HUDOriginalTextSize", original) end)
                end
                obj.TextSize = math.clamp(math.floor(original * textScale + 0.5), 8, 28)
            end
        end
    end

    local function setRole(obj, property, role)
        pcall(function() obj:SetAttribute("HUDThemeRole_" .. property, role) end)
        obj[property] = palette[role]
    end

    local function makeNavIcon(parentObject, kind)
        local asset = resolveNavIconAsset(kind)
        if not asset then return nil end
        local slot = Instance.new("Frame")
        slot.Name = "NavIconSlot"
        slot.Parent = parentObject
        slot.Position = UDim2.new(0, 8, 0.5, -11)
        slot.Size = UDim2.fromOffset(22, 22)
        slot.BorderSizePixel = 0
        slot.BackgroundTransparency = 1
        corner(slot, 6)
        setRole(slot, "BackgroundColor3", "Elev")

        local image = Instance.new("ImageLabel")
        image.Name = "NavIcon"
        image.Parent = slot
        image.AnchorPoint = Vector2.new(0.5, 0.5)
        image.Position = UDim2.fromScale(0.5, 0.5)
        image.Size = UDim2.fromOffset(16, 16)
        image.BackgroundTransparency = 1
        image.BorderSizePixel = 0
        image.Image = asset
        image.ImageTransparency = 0.06
        image.ScaleType = Enum.ScaleType.Fit
        setRole(image, "ImageColor3", "Tx3")
        return { slot=slot, image=image }
    end


    local function makePalette(name)
        local source = THEMES[name] or THEMES.Default
        themeName = THEMES[name] and name or "Default"
        for key, value in pairs(source) do palette[key] = value end
        palette.White = source.White or Color3.fromRGB(255,255,255)
        palette.Tx = source.Tx or palette.White:Lerp(palette.Card, 0.08)
        palette.Tx2 = source.Tx2 or palette.White:Lerp(palette.Card, 0.24)
        palette.Tx3 = source.Tx3 or palette.White:Lerp(palette.Card, 0.43)
        palette.Tx4 = source.Tx4 or palette.White:Lerp(palette.Card, 0.58)
        palette.TgOff = source.TgOff or palette.Bd2:Lerp(palette.Card, 0.35)
        palette.TgOn = source.TgOn or palette.Accent
        palette.KnobOff = source.KnobOff or palette.Tx2
        palette.KnobOn = source.KnobOn or palette.White
        palette.AccentSoft = source.AccentSoft or palette.Accent:Lerp(palette.Card, 0.68)
    end

    root = Instance.new("ScreenGui")
    root.Name = options.Name or "ReusableClickGUI"
    root.ResetOnSpawn = false
    root.DisplayOrder = options.DisplayOrder or 100
    pcall(function() root.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets end)
    root.Parent = parent

    makePalette(themeName)

    local function applyHUDScaleToFrame(frame)
        if not frame or not frame:IsA("GuiObject") or frame.Parent ~= root then return end
        local scaler = frame:FindFirstChild("HUDUserScale")
        if not scaler then
            scaler = Instance.new("UIScale")
            scaler.Name = "HUDUserScale"
            scaler.Parent = frame
        end
        scaler.Scale = hudScale
    end

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Parent = root
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.Size = options.Size or UDim2.fromOffset(920, 590)
    main.BackgroundColor3 = palette.BG
    main.BorderSizePixel = 0
    main.Active = true
    corner(main, 12)
    stroke(main, palette.Bd2, 0.2)
    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(600, 380)
    sizeConstraint.MaxSize = Vector2.new(1500, 1000)
    sizeConstraint.Parent = main

    local accentLine = Instance.new("Frame")
    accentLine.Name = "AccentLine"
    accentLine.Parent = main
    accentLine.Position = UDim2.fromOffset(12, 0)
    accentLine.Size = UDim2.new(1, -24, 0, 1)
    accentLine.BackgroundColor3 = palette.Accent
    accentLine.BorderSizePixel = 0
    accentLine.ZIndex = 10
    setRole(accentLine, "BackgroundColor3", "Accent")
    corner(accentLine, 1)

    local profile = Instance.new("Frame")
    profile.Name = "ProfileHeader"
    profile.Parent = main
    profile.Position = UDim2.fromOffset(8, 48)
    profile.Size = UDim2.fromOffset(124, 54)
    profile.BackgroundColor3 = palette.Card
    profile.BorderSizePixel = 0
    profile.Active = true
    corner(profile, 10)
    local profileStroke = stroke(profile, palette.Bd2, 0.35)
    local profileShadow = shadow(profile, palette.Bd2, 0.45)
    setRole(profileStroke, "Color", "Bd2")
    setRole(profileShadow, "Color", "Bd2")
    setRole(profile, "BackgroundColor3", "Card")

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "Avatar"
    avatar.Parent = profile
    avatar.Position = UDim2.new(0, 8, 0.5, -17)
    avatar.Size = UDim2.fromOffset(34, 34)
    avatar.BackgroundTransparency = 1
    avatar.BorderSizePixel = 0
    avatar.Image = options.AvatarImage or "rbxasset://textures/ui/Guidetool/PlayerIcon.png"
    avatar.ImageColor3 = Color3.fromRGB(254, 254, 254)
    avatar.ScaleType = Enum.ScaleType.Crop
    avatar.ZIndex = 3
    corner(avatar, 9999)
    local avatarStroke = stroke(avatar, palette.Bd2, 0.4)
    setRole(avatarStroke, "Color", "Bd2")
    if not options.AvatarImage and player then
        task.spawn(function()
            local ok, image = pcall(function()
                return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and type(image) == "string" and image ~= "" and avatar.Parent then avatar.Image = image end
        end)
    end

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Parent = main
    sidebar.Position = UDim2.fromOffset(8, 110)
    sidebar.Size = UDim2.fromOffset(124, 293)
    sidebar.BackgroundColor3 = palette.Sidebar
    sidebar.BorderSizePixel = 0
    corner(sidebar, 10)
    stroke(sidebar, palette.Bd2, 0.32)
    local sidePad = pad(sidebar, 8, 8, 8, 8)
    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Parent = sidebar
    sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sideLayout.Padding = UDim.new(0, 3)

    local title = newText(profile, options.Title or (player and player.DisplayName) or "INERTIA", 13, palette.White, Enum.Font.GothamBold)
    title.Position = UDim2.new(0, 49, 0.5, -13)
    title.Size = UDim2.new(1, -56, 0, 15)
    title.LayoutOrder = 1
    title.TextTruncate = Enum.TextTruncate.AtEnd
    setRole(title, "TextColor3", "White")
    local subtitle = newText(profile, options.Subtitle or (player and ("@" .. player.Name)) or "UI ONLY MODULE", 9, palette.Tx3, Enum.Font.GothamMedium)
    subtitle.Position = UDim2.new(0, 49, 0.5, 2)
    subtitle.Size = UDim2.new(1, -56, 0, 11)
    subtitle.LayoutOrder = 2
    subtitle.TextTruncate = Enum.TextTruncate.AtEnd
    setRole(subtitle, "TextColor3", "Tx3")

    local search = Instance.new("TextBox")
    search.Name = "Search"
    search.Parent = sidebar
    search.LayoutOrder = 3
    search.Size = UDim2.new(1, 0, 0, 28)
    search.BackgroundColor3 = palette.Elev
    search.BorderSizePixel = 0
    search.Text = ""
    search.PlaceholderText = translate("Search")
    search.PlaceholderColor3 = palette.Tx3
    search.TextColor3 = palette.Tx
    search.TextSize = 12
    search.Font = Enum.Font.Gotham
    search.ClearTextOnFocus = false
    corner(search, 7)
    stroke(search, palette.Bd2, 0.45)
    pad(search, 9, 9, 0, 0)
    setRole(search, "BackgroundColor3", "Elev")
    setRole(search, "TextColor3", "Tx")
    setRole(search, "PlaceholderColor3", "Tx3")

    local pageList = Instance.new("Frame")
    pageList.Name = "PageList"
    pageList.Parent = sidebar
    pageList.LayoutOrder = 1
    pageList.Size = UDim2.new(1, 0, 1, 0)
    pageList.BackgroundTransparency = 1
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Parent = pageList
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 4)

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Parent = main
    body.Position = UDim2.new(0, 146, 0, 1)
    body.Size = UDim2.new(1, -152, 1, -27)
    body.BackgroundColor3 = palette.BG
    body.BorderSizePixel = 0

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = body
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    local headerTitle = newText(header, "", 16, palette.White, Enum.Font.GothamBold)
    headerTitle.Position = UDim2.new(0, 12, 0, 0)
    headerTitle.Size = UDim2.new(1, -292, 1, 0)
    setRole(headerTitle, "TextColor3", "White")
    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Parent = header
    close.AnchorPoint = Vector2.new(1, 0.5)
    close.Position = UDim2.new(1, -14, 0.5, 0)
    close.Size = UDim2.fromOffset(26, 26)
    close.BackgroundColor3 = palette.Elev
    close.BorderSizePixel = 0
    close.Text = "×"
    close.TextColor3 = palette.Tx2
    close.TextSize = 20
    close.Font = Enum.Font.GothamMedium
    close.AutoButtonColor = false
    corner(close, 7)
    setRole(close, "BackgroundColor3", "Elev")
    setRole(close, "TextColor3", "Tx2")

    search.Parent = header
    search.LayoutOrder = 0
    search.AnchorPoint = Vector2.new(1, 0.5)
    search.Position = UDim2.new(1, -50, 0.5, 0)
    search.Size = UDim2.fromOffset(190, 24)

    local statusBar = Instance.new("Frame")
    statusBar.Name = "Status"
    statusBar.Parent = main
    statusBar.Position = UDim2.new(0, 0, 1, -26)
    statusBar.Size = UDim2.new(1, 0, 0, 26)
    statusBar.BackgroundColor3 = palette.Sidebar
    statusBar.BorderSizePixel = 0
    statusBar.ClipsDescendants = true
    corner(statusBar, 12)
    setRole(statusBar, "BackgroundColor3", "Sidebar")
    local statusTop = Instance.new("Frame")
    statusTop.Parent = statusBar
    statusTop.Size = UDim2.new(1, 0, 0, 1)
    statusTop.BackgroundColor3 = palette.Bd
    statusTop.BackgroundTransparency = 0.3
    statusTop.BorderSizePixel = 0
    setRole(statusTop, "BackgroundColor3", "Bd")
    local statusRole = newText(statusBar, "ROLE  --", 11, palette.Tx2, Enum.Font.GothamMedium)
    statusRole.Position = UDim2.fromOffset(14, 0)
    statusRole.Size = UDim2.fromOffset(150, 26)
    setRole(statusRole, "TextColor3", "Tx2")
    local statusFPS = newText(statusBar, "FPS  --", 11, palette.Tx, Enum.Font.GothamMedium)
    statusFPS.Position = UDim2.fromOffset(180, 0)
    statusFPS.Size = UDim2.fromOffset(85, 26)
    setRole(statusFPS, "TextColor3", "Tx")
    local statusPing = newText(statusBar, "PING  --", 11, palette.Tx3, Enum.Font.GothamMedium)
    statusPing.Position = UDim2.fromOffset(270, 0)
    statusPing.Size = UDim2.fromOffset(95, 26)
    setRole(statusPing, "TextColor3", "Tx3")
    local statusHint = newText(statusBar, "LCtrl = menu  |  RMB = bind", 10, palette.Tx4, Enum.Font.Gotham)
    statusHint.AnchorPoint = Vector2.new(1, 0)
    statusHint.Position = UDim2.new(1, -14, 0, 0)
    statusHint.Size = UDim2.fromOffset(210, 26)
    statusHint.TextXAlignment = Enum.TextXAlignment.Right
    setRole(statusHint, "TextColor3", "Tx4")

    local settingsModal = Instance.new("Frame")
    settingsModal.Name = "Settings"
    settingsModal.Parent = root
    settingsModal.AnchorPoint = Vector2.new(0.5, 0.5)
    settingsModal.Position = options.SettingsPosition or UDim2.new(0.5, 620, 0.5, 0)
    settingsModal.Size = UDim2.fromOffset(300, 530)
    settingsModal.BackgroundColor3 = palette.Card
    settingsModal.BorderSizePixel = 0
    settingsModal.Visible = false
    settingsModal.Active = true
    settingsModal.ZIndex = 1500
    corner(settingsModal, 12)
    stroke(settingsModal, palette.Bd2, 0.15)
    setRole(settingsModal, "BackgroundColor3", "Card")

    local settingsTitle = newText(settingsModal, "Settings", 14, palette.White, Enum.Font.GothamBold)
    settingsTitle.Position = UDim2.fromOffset(14, 8)
    settingsTitle.Size = UDim2.new(1, -52, 0, 26)
    settingsTitle.ZIndex = 1502
    setRole(settingsTitle, "TextColor3", "White")
    registerText(settingsTitle, "Settings", false)
    local settingsClose = Instance.new("TextButton")
    settingsClose.Name = "Close"
    settingsClose.Parent = settingsModal
    settingsClose.AnchorPoint = Vector2.new(1, 0)
    settingsClose.Position = UDim2.new(1, -10, 0, 9)
    settingsClose.Size = UDim2.fromOffset(22, 22)
    settingsClose.BackgroundColor3 = palette.Elev
    settingsClose.BorderSizePixel = 0
    settingsClose.AutoButtonColor = false
    settingsClose.Font = Enum.Font.GothamMedium
    settingsClose.Text = "×"
    settingsClose.TextColor3 = palette.Tx2
    settingsClose.TextSize = 14
    settingsClose.ZIndex = 1502
    corner(settingsClose, 6)
    setRole(settingsClose, "BackgroundColor3", "Elev")
    setRole(settingsClose, "TextColor3", "Tx2")

    local settingsBody = Instance.new("Frame")
    settingsBody.Parent = settingsModal
    settingsBody.Position = UDim2.fromOffset(12, 42)
    settingsBody.Size = UDim2.new(1, -24, 1, -54)
    settingsBody.BackgroundTransparency = 1
    settingsBody.ZIndex = 1501
    local settingsLayout = Instance.new("UIListLayout")
    settingsLayout.Parent = settingsBody
    settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    settingsLayout.Padding = UDim.new(0, 7)

    local settingsValues = {}
    local function makeSettingsChoice(labelKey, labelText, order, getter, values, setter)
        local holder = Instance.new("Frame")
        holder.Name = labelText
        holder.Parent = settingsBody
        holder.LayoutOrder = order
        holder.Size = UDim2.new(1, 0, 0, 48)
        holder.BackgroundTransparency = 1
        local label = newText(holder, labelText, 11, palette.Tx3, Enum.Font.GothamMedium)
        label.Size = UDim2.new(1, 0, 0, 17)
        label.ZIndex = 1502
        setRole(label, "TextColor3", "Tx3")
        registerText(label, labelKey, false)
        local button = Instance.new("TextButton")
        button.Parent = holder
        button.Position = UDim2.fromOffset(0, 20)
        button.Size = UDim2.new(1, 0, 0, 26)
        button.BackgroundColor3 = palette.Elev
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Font = Enum.Font.GothamMedium
        button.TextColor3 = palette.Tx
        button.TextSize = 12
        button.ZIndex = 1502
        corner(button, 7)
        stroke(button, palette.Bd2, 0.4)
        setRole(button, "BackgroundColor3", "Elev")
        setRole(button, "TextColor3", "Tx")
        local function refresh()
            button.Text = tostring(getter())
        end
        connect(button.Activated, function()
            local current = getter()
            local index = table.find(values, current) or 1
            setter(values[index % #values + 1])
            refresh()
        end)
        table.insert(settingsValues, refresh)
        refresh()
        return holder
    end

    makeSettingsChoice("Language", "Language", 1, function() return language end, {"ENG", "RU", "UK", "SPANISH"}, function(value)
        api:SetLanguage(value)
    end)
    makeSettingsChoice("TextSize", "Text Size", 2, function()
        if textScale <= 0.9 then return "Small" end
        if textScale >= 1.15 then return "Large" end
        return "Medium"
    end, {"Small", "Medium", "Large"}, function(value)
        api:SetTextScale(value == "Small" and 0.88 or (value == "Large" and 1.18 or 1))
    end)
    makeSettingsChoice("HUDSize", "HUD Size", 3, function()
        return tostring(math.floor(hudScale * 100 + 0.5)) .. "%"
    end, {"80%", "90%", "100%", "115%", "130%"}, function(value)
        api:SetHUDScale((tonumber(string.match(value, "%d+")) or 100) / 100)
    end)
    makeSettingsChoice("NotificationPosition", "Notification Position", 4, function() return notificationPosition end, {
        "Bottom Right", "Bottom Center", "Bottom Left", "Top Left", "Top Center", "Top Right",
    }, function(value)
        api:SetNotificationPosition(value)
    end)
    makeSettingsChoice("NotificationColor", "Notification Color", 5, function() return notificationColor end, {
        "Theme", "White", "Green", "Yellow", "Red", "Pink",
    }, function(value)
        api:SetNotificationColor(value)
    end)

    local themeHolder = Instance.new("Frame")
    themeHolder.Name = "ThemeStyle"
    themeHolder.Parent = settingsBody
    themeHolder.LayoutOrder = 6
    themeHolder.Size = UDim2.new(1, 0, 0, 144)
    themeHolder.BackgroundTransparency = 1
    local themeTitle = newText(themeHolder, "Theme Style", 11, palette.Tx3, Enum.Font.GothamMedium)
    themeTitle.Size = UDim2.new(1, 0, 0, 17)
    themeTitle.ZIndex = 1502
    setRole(themeTitle, "TextColor3", "Tx3")
    registerText(themeTitle, "ThemeStyle", false)
    local themeGrid = Instance.new("Frame")
    themeGrid.Parent = themeHolder
    themeGrid.Position = UDim2.fromOffset(0, 20)
    themeGrid.Size = UDim2.new(1, 0, 0, 122)
    themeGrid.BackgroundTransparency = 1
    local grid = Instance.new("UIGridLayout")
    grid.Parent = themeGrid
    grid.CellPadding = UDim2.fromOffset(6, 6)
    grid.CellSize = UDim2.new(0.5, -3, 0, 20)
    grid.FillDirectionMaxCells = 2
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    local themeButtons = {}
    for index, name in ipairs({"Default", "Graphite", "Ocean", "Forest", "Wine", "Violet", "Ember", "Amber", "Rose"}) do
        local button = Instance.new("TextButton")
        button.Name = name
        button.Parent = themeGrid
        button.LayoutOrder = index
        button.BackgroundColor3 = palette.Elev
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Font = Enum.Font.GothamMedium
        button.Text = name
        button.TextColor3 = palette.Tx2
        button.TextSize = 10
        button.ZIndex = 1502
        button:SetAttribute("ThemeOption", name)
        corner(button, 6)
        local optionStroke = stroke(button, palette.Bd2, 0.45)
        setRole(optionStroke, "Color", "Bd2")
        themeButtons[name] = button
        connect(button.Activated, function() api:SetTheme(name) end)
    end

    local executorHolder = Instance.new("Frame")
    executorHolder.Name = "Executor"
    executorHolder.Parent = settingsBody
    executorHolder.LayoutOrder = 7
    executorHolder.Size = UDim2.new(1, 0, 0, 48)
    executorHolder.BackgroundTransparency = 1
    local executorTitle = newText(executorHolder, "Executor", 11, palette.Tx3, Enum.Font.GothamMedium)
    executorTitle.Size = UDim2.new(1, 0, 0, 17)
    executorTitle.ZIndex = 1502
    setRole(executorTitle, "TextColor3", "Tx3")
    registerText(executorTitle, "Executor", false)
    local executorValue = newText(executorHolder, options.Executor or "Unknown", 11, palette.Tx, Enum.Font.GothamMedium)
    executorValue.Position = UDim2.fromOffset(0, 20)
    executorValue.Size = UDim2.new(1, 0, 0, 26)
    executorValue.BackgroundTransparency = 0
    executorValue.BackgroundColor3 = palette.Elev
    executorValue.TextXAlignment = Enum.TextXAlignment.Center
    executorValue.ZIndex = 1502
    corner(executorValue, 7)
    setRole(executorValue, "BackgroundColor3", "Elev")
    setRole(executorValue, "TextColor3", "Tx")

    connect(settingsClose.Activated, function() settingsModal.Visible = false end)
    connect(profile.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            settingsModal.Visible = not settingsModal.Visible
        end
    end)

    local function styleTree()
        local function recolor(obj)
            for attribute, role in pairs(obj:GetAttributes()) do
                local property = attribute:match("^HUDThemeRole_(.+)$")
                if property and palette[role] then pcall(function() obj[property] = palette[role] end) end
            end
            if obj == main then obj.BackgroundColor3 = palette.BG end
            if obj == body then obj.BackgroundColor3 = palette.BG end
            if obj == sidebar then obj.BackgroundColor3 = palette.Sidebar end
            if obj == header then obj.BackgroundColor3 = palette.Card end
            if obj:IsA("UIGradient") then
                if obj.Name == "HUDHeaderGradient" then
                    obj.Color = ColorSequence.new(palette.White:Lerp(palette.Accent, 0.14), palette.White:Lerp(palette.Card, 0.06))
                elseif obj.Name == "QuickStatusGradient" then
                    obj.Color = ColorSequence.new(palette.White:Lerp(palette.Accent, 0.16), palette.White:Lerp(palette.Elev, 0.08))
                elseif obj.Name == "DynamicIslandGradient" then
                    obj.Color = ColorSequence.new(palette.White:Lerp(palette.Accent, 0.14), palette.White:Lerp(palette.Card, 0.08))
                elseif obj.Name == "HUDSurfaceGradient" or obj.Name == "NotificationGradient" then
                    obj.Color = ColorSequence.new(palette.White:Lerp(palette.Accent, 0.12), palette.White:Lerp(palette.Elev, 0.08))
                end
            end
        end
        recolor(root)
        for _, obj in ipairs(root:GetDescendants()) do pcall(recolor, obj) end
        for _, item in ipairs(localized) do
            if item.Object and item.Object.Parent then
                local value = translate(item.Key)
                item.Object.Text = item.Uppercase and string.upper(value) or value
            end
        end
        search.PlaceholderText = translate("Search")
        applyTextScale()
        for name, button in pairs(themeButtons) do
            local selected = name == themeName
            button.BackgroundColor3 = selected and palette.ActiveBg or palette.Elev
            button.TextColor3 = selected and palette.White or palette.Tx2
            local optionStroke = button:FindFirstChildOfClass("UIStroke")
            if optionStroke then
                optionStroke.Color = selected and palette.Accent or palette.Bd2
                optionStroke.Transparency = selected and 0.05 or 0.45
            end
        end
        for _, refresh in ipairs(settingsValues) do pcall(refresh) end
        if activePage then showPage(activePage) end
    end

    function api:SetTheme(name)
        makePalette(name)
        styleTree()
        if options.OnThemeChanged then pcall(options.OnThemeChanged, themeName) end
        emitSetting("Theme", themeName)
    end

    function api:SetLanguage(name)
        language = LOCALES[name] and name or "ENG"
        styleTree()
        if options.OnLanguageChanged then pcall(options.OnLanguageChanged, language) end
        emitSetting("Language", language)
    end

    function api:RegisterLocale(name, values)
        LOCALES[name] = LOCALES[name] or {}
        for key, value in pairs(values or {}) do LOCALES[name][key] = value end
        if language == name then styleTree() end
    end

    function api:SetTextScale(scale)
        textScale = math.clamp(tonumber(scale) or 1, 0.8, 1.3)
        applyTextScale()
        for _, refresh in ipairs(settingsValues) do pcall(refresh) end
        if options.OnTextScaleChanged then pcall(options.OnTextScaleChanged, textScale) end
        emitSetting("TextScale", textScale)
    end

    function api:SetHUDScale(scale)
        hudScale = math.clamp(tonumber(scale) or 1, 0.8, 1.3)
        for _, hud in pairs(huds) do
            if type(hud) == "table" and hud.Frame then applyHUDScaleToFrame(hud.Frame) end
        end
        for _, refresh in ipairs(settingsValues) do pcall(refresh) end
        if options.OnHUDScaleChanged then pcall(options.OnHUDScaleChanged, hudScale) end
        emitSetting("HUDScale", hudScale)
    end

    showPage = function(page)
        activePage = page
        for _, data in pairs(pages) do
            local selected = data == page
            data.Page.Visible = selected
            setRole(data.Button, "BackgroundColor3", selected and "ActiveBg" or "Elev")
            data.Button.BackgroundTransparency = selected and 0.16 or 1
            setRole(data.Label, "TextColor3", selected and "White" or "Tx2")
            data.Label.Font = selected and Enum.Font.GothamMedium or Enum.Font.Gotham
            if data.Icon then
                setRole(data.Icon.image, "ImageColor3", selected and "White" or "Tx3")
                data.Icon.image.ImageTransparency = selected and 0 or 0.06
                setRole(data.Icon.slot, "BackgroundColor3", selected and "ActiveBg" or "Elev")
                data.Icon.slot.BackgroundTransparency = selected and 0.24 or 1
            end
        end
        headerTitle.Text = page and translate(page.Name) or ""
    end

    function api:AddPage(name, icon)
        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Parent = body
        page.Position = UDim2.new(0, 0, 0, 42)
        page.Size = UDim2.new(1, 0, 1, -44)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 0
        page.ScrollBarImageColor3 = palette.Tx3
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new()
        page.Visible = false
        local layout = Instance.new("UIListLayout")
        layout.Parent = page
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Parent = pageList
        button.Size = UDim2.new(1, 0, 0, 31)
        button.LayoutOrder = #pages + 1
        button.BackgroundColor3 = palette.Elev
        button.BackgroundTransparency = 1
        button.BorderSizePixel = 0
        button.Text = ""
        button.AutoButtonColor = false
        corner(button, 7)
        setRole(button, "BackgroundColor3", "Elev")
        local iconKind = icon or NAV_ICON_ALIASES[string.lower(name)]
        local navIcon = makeNavIcon(button, iconKind)
        local label = newText(button, name, 12, palette.Tx2, Enum.Font.Gotham)
        label.Position = UDim2.new(0, navIcon and 38 or 10, 0, 0)
        label.Size = UDim2.new(1, navIcon and -48 or -20, 1, 0)
        label.TextTruncate = Enum.TextTruncate.AtEnd
        setRole(label, "TextColor3", "Tx2")
        registerText(label, name, false)
        local data = { Name=name, Page=page, Button=button, Label=label, Icon=navIcon }
        pages[name] = data
        connect(button.Activated, function() showPage(data) end)
        if not activePage then showPage(data) end
        return page
    end

    local function resolvePage(page)
        if type(page) == "string" then
            local data = pages[page]
            return data and data.Page
        end
        return page
    end

    function api:AddSection(page, titleText, order)
        local parentPage = resolvePage(page)
        assert(parentPage, "HUD_ClickGUI_Module: unknown page")
        local card = Instance.new("Frame")
        card.Name = titleText
        card.Parent = parentPage
        card.LayoutOrder = order or 1
        card.Size = UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = palette.Card
        card.BorderSizePixel = 0
        setRole(card, "BackgroundColor3", "Card")
        corner(card, 10)
        stroke(card, palette.Bd, 0.3)
        local inner = Instance.new("Frame")
        inner.Parent = card
        inner.Size = UDim2.new(1, 0, 0, 0)
        inner.AutomaticSize = Enum.AutomaticSize.Y
        inner.BackgroundTransparency = 1
        pad(inner, 12, 12, 12, 12)
        local layout = Instance.new("UIListLayout")
        layout.Parent = inner
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 6)
        local heading = newText(inner, "", 12, palette.Tx3, Enum.Font.GothamBold)
        heading.Size = UDim2.new(1, 0, 0, 20)
        heading.LayoutOrder = 0
        registerText(heading, titleText, true)
        return inner
    end

    -- Creates two independent cards with stable adjacent ordering. This keeps long forms balanced
    -- instead of forcing every control into one card that can grow beyond the visible page area.
    function api:AddSectionPair(page, firstTitle, secondTitle, order)
        local baseOrder = tonumber(order) or 1
        local first = api:AddSection(page, firstTitle, baseOrder)
        local second = api:AddSection(page, secondTitle, baseOrder + 0.25)
        return first, second
    end

    function api:AddToggle(section, label, default, callback, order)
        local row = Instance.new("TextButton")
        row.Name = label
        row.Parent = section
        row.LayoutOrder = order or 1
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundColor3 = palette.Elev
        row.BorderSizePixel = 0
        row.Text = ""
        row.AutoButtonColor = false
        corner(row, 7)
        local text = newText(row, label, 12, palette.Tx2, Enum.Font.Gotham)
        text.Position = UDim2.new(0, 9, 0, 0)
        text.Size = UDim2.new(1, -68, 1, 0)
        text.TextTruncate = Enum.TextTruncate.AtEnd
        registerText(text, label, false)
        local value = default == true
        local pill = Instance.new("TextLabel")
        pill.Parent = row
        pill.AnchorPoint = Vector2.new(1, 0.5)
        pill.Position = UDim2.new(1, -9, 0.5, 0)
        pill.Size = UDim2.fromOffset(42, 18)
        pill.BackgroundColor3 = value and palette.TgOn or palette.TgOff
        pill.Text = value and "ON" or "OFF"
        pill.TextColor3 = value and palette.KnobOn or palette.Tx3
        pill.TextSize = 10
        pill.Font = Enum.Font.GothamBold
        corner(pill, 9)
        local control = { Type="Toggle", Row=row, Get=function() return value end }
        function control:Set(v, silent)
            value = v == true
            pill.BackgroundColor3 = value and palette.TgOn or palette.TgOff
            pill.Text = value and "ON" or "OFF"
            pill.TextColor3 = value and palette.KnobOn or palette.Tx3
            text.TextColor3 = value and palette.Tx or palette.Tx2
            if not silent and callback then pcall(callback, value) end
        end
        connect(row.Activated, function() control:Set(not value, false) end)
        controls[string.lower(label)] = control
        control:Set(value, true)
        return control
    end

    function api:AddAction(section, label, callback, order)
        local button = Instance.new("TextButton")
        button.Name = label
        button.Parent = section
        button.LayoutOrder = order or 1
        button.Size = UDim2.new(1, 0, 0, 32)
        button.BackgroundColor3 = palette.Elev
        button.BorderSizePixel = 0
        button.TextColor3 = palette.Tx
        button.TextSize = 12
        button.Font = Enum.Font.GothamMedium
        button.AutoButtonColor = false
        corner(button, 7)
        registerText(button, label, false)
        connect(button.Activated, function() if callback then pcall(callback) end end)
        return button
    end

    -- Responsive stacked input used for long values such as API keys, phrases and asset IDs. Keeping
    -- the caption above the field prevents text from entering a neighboring card on narrow layouts.
    function api:AddInput(section, label, default, callback, order, inputOptions)
        inputOptions = inputOptions or {}
        local row = Instance.new("Frame")
        row.Name = label
        row.Parent = section
        row.LayoutOrder = order or 1
        row.Size = UDim2.new(1, 0, 0, 52)
        row.BackgroundTransparency = 1
        row.ClipsDescendants = true

        local caption = newText(row, label, 12, palette.Tx2, Enum.Font.Gotham)
        caption.Position = UDim2.fromOffset(6, 0)
        caption.Size = UDim2.new(1, -12, 0, 18)
        caption.TextTruncate = Enum.TextTruncate.AtEnd
        setRole(caption, "TextColor3", "Tx2")
        registerText(caption, label, false)

        local box = Instance.new("TextBox")
        box.Name = "Input"
        box.Parent = row
        box.Position = UDim2.fromOffset(6, 22)
        box.Size = UDim2.new(1, -12, 0, 24)
        box.BackgroundColor3 = palette.Elev
        box.BorderSizePixel = 0
        box.Font = Enum.Font.Gotham
        box.TextSize = 12
        box.TextColor3 = palette.Tx
        box.PlaceholderText = tostring(inputOptions.Placeholder or "")
        box.PlaceholderColor3 = palette.Tx4
        box.Text = tostring(default or "")
        box.ClearTextOnFocus = inputOptions.ClearTextOnFocus == true
        box.TextXAlignment = inputOptions.Centered == true and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
        box.TextWrapped = false
        box.MultiLine = false
        pcall(function() box.TextTruncate = Enum.TextTruncate.AtEnd end)
        corner(box, 5)
        local boxStroke = stroke(box, palette.Bd2, 0.4)
        pad(box, 7, 7, 0, 0)
        setRole(box, "BackgroundColor3", "Elev")
        setRole(box, "TextColor3", "Tx")
        setRole(box, "PlaceholderColor3", "Tx4")
        setRole(boxStroke, "Color", "Bd2")

        local value = box.Text
        local suppressChange = false
        local control = { Type="Input", Row=row, Box=box }
        function control:Get()
            return value
        end
        function control:Set(newValue, silent)
            value = tostring(newValue or "")
            suppressChange = true
            box.Text = value
            suppressChange = false
            if not silent and callback then pcall(callback, value) end
        end

        local function commit(trimValue)
            if suppressChange then return end
            local nextValue = box.Text
            if trimValue ~= false and inputOptions.Trim ~= false then
                nextValue = nextValue:gsub("^%s+", ""):gsub("%s+$", "")
                if nextValue ~= box.Text then
                    suppressChange = true
                    box.Text = nextValue
                    suppressChange = false
                end
            end
            if nextValue == value then return end
            value = nextValue
            if callback then pcall(callback, value) end
        end

        if inputOptions.Live == true then
            connect(box:GetPropertyChangedSignal("Text"), function() commit(false) end)
            connect(box.FocusLost, function() commit(true) end)
        else
            connect(box.FocusLost, function() commit(true) end)
        end
        controls[string.lower(label)] = control
        return control
    end

    api.AddTextInput = api.AddInput
    api.AddTextBox = api.AddInput

    function api:AddCycle(section, label, values, default, callback, order)
        local row = Instance.new("Frame")
        row.Parent = section
        row.LayoutOrder = order or 1
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.ClipsDescendants = true
        local text = newText(row, label, 12, palette.Tx2, Enum.Font.Gotham)
        text.Size = UDim2.new(1, -132, 1, 0)
        text.TextTruncate = Enum.TextTruncate.AtEnd
        registerText(text, label, false)
        local button = Instance.new("TextButton")
        button.Parent = row
        button.AnchorPoint = Vector2.new(1, 0.5)
        button.Position = UDim2.new(1, 0, 0.5, 0)
        button.Size = UDim2.fromOffset(120, 22)
        button.BackgroundColor3 = palette.Elev
        button.BorderSizePixel = 0
        button.TextColor3 = palette.Tx
        button.TextSize = 11
        button.Font = Enum.Font.GothamMedium
        button.AutoButtonColor = false
        pcall(function() button.TextTruncate = Enum.TextTruncate.AtEnd end)
        corner(button, 6)
        local index = table.find(values, default) or 1
        local control = { Type="Cycle", Row=row }
        function control:Get() return values[index] end
        local function apply(fire)
            button.Text = tostring(values[index])
            if fire and callback then pcall(callback, values[index]) end
        end
        function control:Set(value, silent)
            local found = table.find(values, value)
            if found then index = found; apply(not silent) end
        end
        connect(button.Activated, function()
            index = index % #values + 1
            apply(true)
        end)
        apply(false)
        controls[string.lower(label)] = control
        return control
    end

    function api:AddSlider(section, label, min, max, default, callback, order)
        local row = Instance.new("Frame")
        row.Parent = section
        row.LayoutOrder = order or 1
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundTransparency = 1
        local text = newText(row, label, 12, palette.Tx2, Enum.Font.Gotham)
        text.Size = UDim2.new(0.65, 0, 0, 18)
        registerText(text, label, false)
        local valueText = newText(row, "", 12, palette.White, Enum.Font.GothamMedium)
        valueText.AnchorPoint = Vector2.new(1, 0)
        valueText.Position = UDim2.new(1, 0, 0, 0)
        valueText.Size = UDim2.new(0.25, 0, 0, 18)
        valueText.TextXAlignment = Enum.TextXAlignment.Right
        local bar = Instance.new("Frame")
        bar.Parent = row
        bar.Position = UDim2.new(0, 0, 0, 26)
        bar.Size = UDim2.new(1, 0, 0, 5)
        bar.BackgroundColor3 = palette.TgOff
        bar.BorderSizePixel = 0
        corner(bar, 3)
        local fill = Instance.new("Frame")
        fill.Parent = bar
        fill.BackgroundColor3 = palette.Accent
        fill.BorderSizePixel = 0
        corner(fill, 3)
        local value = tonumber(default) or min
        local active = false
        local function setValue(newValue, fire)
            value = math.clamp(math.floor(newValue + 0.5), min, max)
            local pct = math.clamp((value - min) / math.max(max - min, 1), 0, 1)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            valueText.Text = tostring(value)
            if fire and callback then pcall(callback, value) end
        end
        local function fromInput(input)
            local pct = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            setValue(min + (max - min) * pct, true)
        end
        connect(row.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then active = true; fromInput(input) end
        end)
        connect(UIS.InputChanged, function(input)
            if active and input.UserInputType == Enum.UserInputType.MouseMovement then fromInput(input) end
        end)
        connect(UIS.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then active = false end
        end)
        local control = { Type="Slider", Row=row, Get=function() return value end, Set=function(_, v, silent) setValue(tonumber(v) or value, not silent) end }
        controls[string.lower(label)] = control
        setValue(value, false)
        return control
    end

    function api:AddHUD(name, hudOptions)
        hudOptions = hudOptions or {}
        local frame = Instance.new("Frame")
        frame.Name = "HUD_" .. name
        frame.Parent = root
        frame.Active = true
        frame.Visible = hudOptions.Visible == true
        frame.Position = hudOptions.Position or UDim2.fromOffset(20, 120)
        frame.Size = hudOptions.Size or UDim2.fromOffset(250, 74)
        frame.BackgroundColor3 = palette.Card
        frame.BackgroundTransparency = 0.01
        frame.BorderSizePixel = 0
        frame.ZIndex = hudOptions.ZIndex or 800
        corner(frame, 11)
        setRole(frame, "BackgroundColor3", "Card")
        local frameStroke = stroke(frame, palette.Bd2, 0.22)
        setRole(frameStroke, "Color", "Bd2")
        local frameShadow = shadow(frame, palette.Bd2, 0.76)
        setRole(frameShadow, "Color", "Bd2")
        gradient(frame, "HUDSurfaceGradient", palette.White:Lerp(palette.Accent, 0.12), palette.White:Lerp(palette.Elev, 0.08), 90)
        local top = Instance.new("Frame")
        top.Name = "tb"
        top.Parent = frame
        top.Size = UDim2.new(1, 0, 0, 28)
        top.BackgroundColor3 = palette.Elev
        top.BackgroundTransparency = 0.025
        top.BorderSizePixel = 0
        top.ZIndex = frame.ZIndex + 1
        corner(top, 10)
        setRole(top, "BackgroundColor3", "Elev")
        gradient(top, "HUDHeaderGradient", palette.White:Lerp(palette.Accent, 0.14), palette.White:Lerp(palette.Card, 0.06), 0)
        local topLine = Instance.new("Frame")
        topLine.Parent = top
        topLine.AnchorPoint = Vector2.new(0, 1)
        topLine.Position = UDim2.new(0, 0, 1, 0)
        topLine.Size = UDim2.new(1, 0, 0, 1)
        topLine.BackgroundColor3 = palette.Bd
        topLine.BackgroundTransparency = 0.2
        topLine.BorderSizePixel = 0
        topLine.ZIndex = frame.ZIndex + 1
        setRole(topLine, "BackgroundColor3", "Bd")
        local tick = Instance.new("Frame")
        tick.Parent = top
        tick.Position = UDim2.new(0, 8, 0.5, -6)
        tick.Size = UDim2.fromOffset(2, 12)
        tick.BackgroundColor3 = palette.Accent
        tick.BorderSizePixel = 0
        tick.ZIndex = frame.ZIndex + 2
        corner(tick, 2)
        setRole(tick, "BackgroundColor3", "Accent")
        local heading = newText(top, "", 11, palette.Tx3, Enum.Font.GothamBold)
        heading.Position = UDim2.new(0, 16, 0, 0)
        heading.Size = UDim2.new(1, -18, 1, 0)
        heading.ZIndex = frame.ZIndex + 2
        setRole(heading, "TextColor3", "Tx")
        registerText(heading, name, true)
        local content = newText(frame, hudOptions.Text or "", 13, palette.Tx, Enum.Font.GothamMedium)
        content.Position = UDim2.new(0, 10, 0, 33)
        content.Size = UDim2.new(1, -20, 1, -40)
        content.TextWrapped = true
        content.ZIndex = frame.ZIndex + 2
        local dragHandle = hudOptions.DragHandle == false and frame or top
        local dragging, startInput, startPos = false, nil, nil
        connect(dragHandle.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; startInput = input.Position; startPos = frame.Position end
        end)
        connect(UIS.InputChanged, function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and startInput and startPos then
                local delta = input.Position - startInput
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        connect(UIS.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                if options.OnHUDMoved then pcall(options.OnHUDMoved, name, frame.Position) end
            end
        end)
        local hud = { Frame=frame, Content=content, SetVisible=function(_, visible) frame.Visible = visible == true end, SetText=function(_, value) content.Text = tostring(value or "") end }
        huds[name] = hud
        applyHUDScaleToFrame(frame)
        return hud
    end

    function api:SetStatus(role, fps, ping)
        statusRole.Text = "ROLE  " .. string.upper(tostring(role or "--"))
        statusFPS.Text = "FPS  " .. tostring(fps or "--")
        statusPing.Text = "PING  " .. tostring(ping or "--")
    end

    function api:AddQuickStatus(hudOptions)
        hudOptions = hudOptions or {}
        local frame = Instance.new("Frame")
        frame.Name = "HUD_QuickStatus"
        frame.Parent = main
        frame.Position = hudOptions.Position or UDim2.fromOffset(8, 410)
        frame.Size = hudOptions.Size or UDim2.fromOffset(124, 150)
        frame.BackgroundColor3 = palette.Card
        frame.BackgroundTransparency = 0.01
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Visible = hudOptions.Visible ~= false
        frame.ZIndex = 25
        corner(frame, 10)
        local frameStroke = stroke(frame, palette.Bd2, 0.32)
        setRole(frame, "BackgroundColor3", "Card")
        setRole(frameStroke, "Color", "Bd2")
        gradient(frame, "QuickStatusGradient", palette.White:Lerp(palette.Accent, 0.16), palette.White:Lerp(palette.Elev, 0.08), 90)

        local header = Instance.new("Frame")
        header.Name = "QuickHeader"
        header.Parent = frame
        header.Position = UDim2.fromOffset(5, 5)
        header.Size = UDim2.new(1, -10, 0, 26)
        header.BackgroundTransparency = 0.16
        header.BorderSizePixel = 0
        header.ZIndex = 26
        corner(header, 7)
        setRole(header, "BackgroundColor3", "Elev")
        local headMark = Instance.new("Frame")
        headMark.Parent = header
        headMark.Position = UDim2.new(0, 7, 0.5, -5)
        headMark.Size = UDim2.fromOffset(2, 10)
        headMark.BorderSizePixel = 0
        headMark.ZIndex = 27
        corner(headMark, 2)
        setRole(headMark, "BackgroundColor3", "Accent")
        local heading = newText(header, "QUICK STATUS", 10, palette.Tx2, Enum.Font.GothamBold)
        heading.Position = UDim2.fromOffset(15, 0)
        heading.Size = UDim2.new(1, -28, 1, 0)
        heading.ZIndex = 27
        setRole(heading, "TextColor3", "Tx2")
        local statusDot = Instance.new("Frame")
        statusDot.Parent = header
        statusDot.AnchorPoint = Vector2.new(1, 0.5)
        statusDot.Position = UDim2.new(1, -7, 0.5, 0)
        statusDot.Size = UDim2.fromOffset(5, 5)
        statusDot.BorderSizePixel = 0
        statusDot.ZIndex = 27
        corner(statusDot, 5)
        setRole(statusDot, "BackgroundColor3", "Accent")

        local body = Instance.new("Frame")
        body.Parent = frame
        body.Position = UDim2.fromOffset(0, 35)
        body.Size = UDim2.new(1, 0, 1, -40)
        body.BackgroundTransparency = 1
        body.ZIndex = 26
        local values = {}
        local function row(key, order)
            local holder = Instance.new("Frame")
            holder.Parent = body
            holder.Position = UDim2.new(0, 9, (order - 1) * 0.25, 0)
            holder.Size = UDim2.new(1, -18, 0.25, 0)
            holder.BackgroundTransparency = 1
            holder.ZIndex = 26
            if order > 1 then
                local line = Instance.new("Frame")
                line.Parent = holder
                line.Size = UDim2.new(1, 0, 0, 1)
                line.BackgroundTransparency = 0.6
                line.BorderSizePixel = 0
                line.ZIndex = 26
                setRole(line, "BackgroundColor3", "Bd")
            end
            local label = newText(holder, key, 9, palette.Tx4, Enum.Font.GothamMedium)
            label.Size = UDim2.new(0, 48, 1, 0)
            label.ZIndex = 27
            setRole(label, "TextColor3", "Tx4")
            local value = newText(holder, "--", 10, palette.Tx, Enum.Font.GothamMedium)
            value.Position = UDim2.fromOffset(48, 0)
            value.Size = UDim2.new(1, -48, 1, 0)
            value.TextXAlignment = Enum.TextXAlignment.Right
            value.TextTruncate = Enum.TextTruncate.AtEnd
            value.ZIndex = 27
            setRole(value, "TextColor3", "Tx")
            values[key] = value
        end
        row("ROLE", 1)
        row("ROUND", 2)
        row("ACTIVE", 3)
        row("NETWORK", 4)
        local hud = {
            Frame=frame,
            Values=values,
            SetVisible=function(_, visible) frame.Visible = visible == true end,
            Set=function(_, key, value)
                if values[key] then values[key].Text = tostring(value or "--") end
            end,
        }
        huds.QuickStatus = hud
        return hud
    end

    function api:AddDynamicIsland(hudOptions)
        hudOptions = hudOptions or {}
        local frame = Instance.new("Frame")
        frame.Name = "HUD_DynamicIsland"
        frame.Parent = root
        frame.AnchorPoint = Vector2.new(0.5, 0)
        frame.Position = hudOptions.Position or UDim2.new(0.5, 0, 0, 20)
        frame.Size = hudOptions.Size or UDim2.fromOffset(336, 40)
        frame.BackgroundColor3 = palette.Sidebar
        frame.BackgroundTransparency = 0.015
        frame.BorderSizePixel = 0
        frame.Visible = hudOptions.Visible == true
        frame.ZIndex = hudOptions.ZIndex or 1800
        corner(frame, 18)
        local frameStroke = stroke(frame, palette.Bd2, 0.18)
        setRole(frame, "BackgroundColor3", "Sidebar")
        setRole(frameStroke, "Color", "Bd2")
        gradient(frame, "DynamicIslandGradient", palette.White:Lerp(palette.Accent, 0.14), palette.White:Lerp(palette.Card, 0.08), 90)
        local dot = Instance.new("Frame")
        dot.Parent = frame
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.Position = UDim2.fromOffset(12, 20)
        dot.Size = UDim2.fromOffset(6, 6)
        dot.BackgroundColor3 = palette.Accent
        dot.BorderSizePixel = 0
        dot.ZIndex = frame.ZIndex + 2
        corner(dot, 6)
        setRole(dot, "BackgroundColor3", "Accent")
        local brand = newText(frame, hudOptions.Title or "INERTIA", 11, palette.White, Enum.Font.GothamBold)
        brand.Position = UDim2.fromOffset(24, 0)
        brand.Size = UDim2.fromOffset(74, 40)
        brand.ZIndex = frame.ZIndex + 2
        setRole(brand, "TextColor3", "White")
        local values = {}
        local definitions = {
            {"ROLE", 102, 78}, {"PING", 184, 48}, {"FPS", 236, 42}, {"TIME", 282, 44},
        }
        for _, definition in ipairs(definitions) do
            local key, x, width = definition[1], definition[2], definition[3]
            local holder = Instance.new("Frame")
            holder.Parent = frame
            holder.Position = UDim2.fromOffset(x, 5)
            holder.Size = UDim2.fromOffset(width, 30)
            holder.BackgroundTransparency = 1
            local label = newText(holder, key, 7, palette.Tx4, Enum.Font.GothamBold)
            label.Size = UDim2.new(1, 0, 0, 11)
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.ZIndex = frame.ZIndex + 2
            setRole(label, "TextColor3", "Tx4")
            local value = newText(holder, "--", 10, palette.Tx, Enum.Font.GothamMedium)
            value.Position = UDim2.fromOffset(0, 11)
            value.Size = UDim2.new(1, 0, 0, 17)
            value.TextXAlignment = Enum.TextXAlignment.Center
            value.TextTruncate = Enum.TextTruncate.AtEnd
            value.ZIndex = frame.ZIndex + 2
            setRole(value, "TextColor3", "Tx")
            values[key] = value
        end
        local hud = {
            Frame=frame,
            Values=values,
            Dot=dot,
            SetVisible=function(_, visible) frame.Visible = visible == true end,
            Set=function(_, key, value)
                if values[key] then values[key].Text = tostring(value or "--") end
            end,
        }
        huds.DynamicIsland = hud
        applyHUDScaleToFrame(frame)
        return hud
    end

    function api:AddKeybindHUD(hudOptions)
        hudOptions = hudOptions or {}
        local hud = api:AddHUD("Keybinds", {
            Position=hudOptions.Position or UDim2.fromOffset(10, 370),
            Size=hudOptions.Size or UDim2.fromOffset(260, 150),
            Visible=hudOptions.Visible == true,
            ZIndex=hudOptions.ZIndex or 851,
        })
        hud.Content:Destroy()
        local list = Instance.new("Frame")
        list.Name = "List"
        list.Parent = hud.Frame
        list.Position = UDim2.fromOffset(8, 32)
        list.Size = UDim2.new(1, -16, 1, -38)
        list.BackgroundTransparency = 1
        local layout = Instance.new("UIListLayout")
        layout.Parent = list
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        local function setBindings(bindings)
            for _, child in ipairs(list:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
            for order, binding in ipairs(bindings or {}) do
                local row = Instance.new("Frame")
                row.Name = tostring(binding.Name or "Binding")
                row.Parent = list
                row.LayoutOrder = order
                row.Size = UDim2.new(1, 0, 0, 25)
                row.BackgroundColor3 = palette.Elev
                row.BackgroundTransparency = 0.08
                row.BorderSizePixel = 0
                corner(row, 6)
                setRole(row, "BackgroundColor3", "Elev")
                local key = newText(row, tostring(binding.Key or "--"), 10, palette.Tx2, Enum.Font.GothamBold)
                key.Position = UDim2.fromOffset(7, 0)
                key.Size = UDim2.fromOffset(48, 25)
                key.TextXAlignment = Enum.TextXAlignment.Center
                setRole(key, "TextColor3", "Tx2")
                local name = newText(row, tostring(binding.Name or "Binding"), 11, palette.Tx, Enum.Font.GothamMedium)
                name.Position = UDim2.fromOffset(62, 0)
                name.Size = UDim2.new(1, -76, 1, 0)
                name.TextTruncate = Enum.TextTruncate.AtEnd
                setRole(name, "TextColor3", "Tx")
                local state = Instance.new("Frame")
                state.Parent = row
                state.AnchorPoint = Vector2.new(1, 0.5)
                state.Position = UDim2.new(1, -8, 0.5, 0)
                state.Size = UDim2.fromOffset(5, 5)
                state.BackgroundColor3 = binding.Active and palette.Accent or palette.Tx3
                state.BorderSizePixel = 0
                corner(state, 5)
                setRole(state, "BackgroundColor3", binding.Active and "Accent" or "Tx3")
            end
            hud.Frame.Size = UDim2.fromOffset(hud.Frame.Size.X.Offset, 42 + math.max(#(bindings or {}), 1) * 29)
        end
        hud.List = list
        hud.SetBindings = function(_, bindings) setBindings(bindings) end
        huds.Keybinds = hud
        setBindings(hudOptions.Bindings or {})
        return hud
    end

    function api:AddPinnedEmotesHUD(hudOptions)
        hudOptions = hudOptions or {}
        local hud = api:AddHUD("Pinned Emotes", {
            Position=hudOptions.Position or UDim2.fromOffset(230, 540),
            Size=hudOptions.Size or UDim2.fromOffset(168, 112),
            Visible=hudOptions.Visible == true,
            ZIndex=hudOptions.ZIndex or 865,
        })
        hud.Content:Destroy()
        local count = newText(hud.Frame, "0", 10, palette.Tx, Enum.Font.GothamMedium)
        count.AnchorPoint = Vector2.new(1, 0)
        count.Position = UDim2.new(1, -9, 0, 5)
        count.Size = UDim2.fromOffset(24, 16)
        count.BackgroundTransparency = 0
        count.BackgroundColor3 = palette.ActiveBg
        count.TextXAlignment = Enum.TextXAlignment.Center
        count.ZIndex = 868
        corner(count, 5)
        setRole(count, "BackgroundColor3", "ActiveBg")
        setRole(count, "TextColor3", "Tx")
        local gridHolder = Instance.new("Frame")
        gridHolder.Parent = hud.Frame
        gridHolder.Position = UDim2.fromOffset(8, 32)
        gridHolder.Size = UDim2.new(1, -16, 1, -40)
        gridHolder.BackgroundTransparency = 1
        local layout = Instance.new("UIGridLayout")
        layout.Parent = gridHolder
        layout.CellPadding = UDim2.fromOffset(5, 5)
        layout.CellSize = UDim2.fromOffset(72, 26)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        local function setEmotes(emotes)
            for _, child in ipairs(gridHolder:GetChildren()) do if not child:IsA("UIGridLayout") then child:Destroy() end end
            for order, emote in ipairs(emotes or {}) do
                local button = Instance.new("TextButton")
                button.Name = tostring(emote.Name or emote)
                button.Parent = gridHolder
                button.LayoutOrder = order
                button.BackgroundColor3 = palette.Elev
                button.BorderSizePixel = 0
                button.AutoButtonColor = false
                button.Font = Enum.Font.GothamMedium
                button.Text = tostring(emote.Name or emote)
                button.TextColor3 = palette.Tx
                button.TextSize = 10
                button.TextTruncate = Enum.TextTruncate.AtEnd
                corner(button, 6)
                local buttonStroke = stroke(button, palette.Bd2, 0.42)
                setRole(button, "BackgroundColor3", "Elev")
                setRole(button, "TextColor3", "Tx")
                setRole(buttonStroke, "Color", "Bd2")
                connect(button.Activated, function()
                    if options.OnPinnedEmote then pcall(options.OnPinnedEmote, emote) end
                end)
                connect(button.MouseButton2Click, function()
                    if options.OnPinnedEmoteUnpin then pcall(options.OnPinnedEmoteUnpin, emote) end
                end)
            end
            local total = #(emotes or {})
            count.Text = tostring(total)
            local rows = math.max(1, math.ceil(total / 2))
            local targetHeight = 42 + rows * 31
            TweenService:Create(hud.Frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(168, targetHeight),
            }):Play()
        end
        hud.Count = count
        hud.Grid = gridHolder
        hud.SetEmotes = function(_, emotes) setEmotes(emotes) end
        huds.PinnedEmotes = hud
        setEmotes(hudOptions.Emotes or {})
        return hud
    end

    function api:AddKillFeedHUD(hudOptions)
        hudOptions = hudOptions or {}
        local hud = api:AddHUD("Kill Feed", {
            Position=hudOptions.Position or UDim2.new(1, -280, 0, 310),
            Size=hudOptions.Size or UDim2.fromOffset(270, 132),
            Visible=hudOptions.Visible == true,
            ZIndex=hudOptions.ZIndex or 870,
        })
        hud.Content:Destroy()
        local list = Instance.new("Frame")
        list.Parent = hud.Frame
        list.Position = UDim2.fromOffset(8, 32)
        list.Size = UDim2.new(1, -16, 1, -40)
        list.BackgroundTransparency = 1
        local layout = Instance.new("UIListLayout")
        layout.Parent = list
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)
        local entries = {}
        local function addEntry(killer, victim)
            table.insert(entries, 1, {Killer=tostring(killer or "?"), Victim=tostring(victim or "?")})
            while #entries > 4 do table.remove(entries) end
            for _, child in ipairs(list:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
            for order, item in ipairs(entries) do
                local row = newText(list, item.Killer .. "  ›  " .. item.Victim, 11, palette.Tx, Enum.Font.GothamMedium)
                row.Name = "FeedEntry"
                row.LayoutOrder = order
                row.Size = UDim2.new(1, 0, 0, 22)
                row.BackgroundTransparency = 0
                row.BackgroundColor3 = palette.Elev
                row.TextXAlignment = Enum.TextXAlignment.Center
                corner(row, 6)
                setRole(row, "BackgroundColor3", "Elev")
                setRole(row, "TextColor3", "Tx")
            end
        end
        hud.List = list
        hud.AddEntry = function(_, killer, victim) addEntry(killer, victim) end
        hud.Clear = function()
            table.clear(entries)
            for _, child in ipairs(list:GetChildren()) do if not child:IsA("UIListLayout") then child:Destroy() end end
        end
        huds.KillFeed = hud
        return hud
    end

    function api:CreateHUDSuite(suiteOptions)
        suiteOptions = suiteOptions or {}
        local suite = {}
        suite.QuickStatus = api:AddQuickStatus({ Visible=suiteOptions.QuickStatus ~= false })
        suite.DynamicIsland = api:AddDynamicIsland({ Visible=suiteOptions.DynamicIsland == true })
        suite.Keybinds = api:AddKeybindHUD({ Visible=suiteOptions.Keybinds == true, Bindings=suiteOptions.Bindings })
        suite.GunStatus = api:AddHUD("Gun Status", { Position=UDim2.new(1,-272,0,200), Size=UDim2.fromOffset(260,96), Visible=suiteOptions.GunStatus == true, Text="Gun: --\nHolder: --" })
        suite.Role = api:AddHUD("Role HUD", { Position=UDim2.fromOffset(10,100), Size=UDim2.fromOffset(260,118), Visible=suiteOptions.Role == true, Text="Role: --\nRound: --" })
        suite.FPS = api:AddHUD("FPS", { Position=UDim2.new(1,-142,0,290), Size=UDim2.fromOffset(130,66), Visible=suiteOptions.FPS == true, Text="--" })
        suite.Ping = api:AddHUD("Ping", { Position=UDim2.new(1,-142,0,362), Size=UDim2.fromOffset(130,66), Visible=suiteOptions.Ping == true, Text="-- ms" })
        suite.Speed = api:AddHUD("Speed", { Position=UDim2.new(1,-142,0,434), Size=UDim2.fromOffset(130,66), Visible=suiteOptions.Speed == true, Text="-- sps" })
        suite.Session = api:AddHUD("Session", { Position=UDim2.new(1,-142,0,506), Size=UDim2.fromOffset(130,66), Visible=suiteOptions.Session == true, Text="00:00:00" })
        suite.Coords = api:AddHUD("Coords", { Position=UDim2.fromOffset(10,540), Size=UDim2.fromOffset(190,66), Visible=suiteOptions.Coords == true, Text="X --  Y --  Z --" })
        suite.PinnedEmotes = api:AddPinnedEmotesHUD({ Visible=suiteOptions.PinnedEmotes == true, Emotes=suiteOptions.Emotes })
        suite.KillFeed = api:AddKillFeedHUD({ Visible=suiteOptions.KillFeed == true })
        return suite
    end

    local notificationHost = Instance.new("Frame")
    notificationHost.Name = "Notifications"
    notificationHost.Parent = root
    notificationHost.BackgroundTransparency = 1
    notificationHost.BorderSizePixel = 0
    notificationHost.Size = UDim2.fromOffset(392, 360)
    notificationHost.ZIndex = 2000
    local notificationLayout = Instance.new("UIListLayout")
    notificationLayout.Parent = notificationHost
    notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notificationLayout.Padding = UDim.new(0, 6)

    local notificationPositions = {
        ["Bottom Right"] = true, ["Bottom Center"] = true, ["Bottom Left"] = true,
        ["Top Left"] = true, ["Top Center"] = true, ["Top Right"] = true,
    }
    local function placeNotifications()
        if not notificationPositions[notificationPosition] then notificationPosition = "Bottom Right" end
        local top = notificationPosition:sub(1, 3) == "Top"
        local left = notificationPosition:sub(-4) == "Left"
        local right = notificationPosition:sub(-5) == "Right"
        local xScale = left and 0 or (right and 1 or 0.5)
        local yScale = top and 0 or 1
        notificationHost.AnchorPoint = Vector2.new(xScale, yScale)
        notificationHost.Position = UDim2.new(xScale, left and 20 or (right and -20 or 0), yScale, top and 20 or -82)
        notificationLayout.HorizontalAlignment = left and Enum.HorizontalAlignment.Left
            or (right and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Center)
        notificationLayout.VerticalAlignment = top and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom
        for _, entry in ipairs(notifications) do
            if entry.Slot and entry.Slot.Parent then
                entry.Slot.LayoutOrder = top and -entry.Order or entry.Order
            end
        end
    end

    function api:SetNotificationPosition(value)
        notificationPosition = notificationPositions[value] and value or "Bottom Right"
        placeNotifications()
        for _, refresh in ipairs(settingsValues) do pcall(refresh) end
        if options.OnNotificationPositionChanged then
            pcall(options.OnNotificationPositionChanged, notificationPosition)
        end
        emitSetting("NotificationPosition", notificationPosition)
    end

    function api:SetNotificationColor(value)
        notificationColor = NOTIFICATION_COLORS[value] ~= nil and value or "Theme"
        for _, refresh in ipairs(settingsValues) do pcall(refresh) end
        if options.OnNotificationColorChanged then
            pcall(options.OnNotificationColorChanged, notificationColor)
        end
        emitSetting("NotificationColor", notificationColor)
    end

    placeNotifications()

    function api:Notify(titleText, messageText, duration, style)
        notificationOrder = notificationOrder + 1
        local styleName = type(style) == "table" and style.Kind or style
        local roleReveal = styleName == "RoundRoles"
        local accent = type(style) == "table" and typeof(style.Color) == "Color3" and style.Color or nil
        if not accent then
            if styleName == "Success" then accent = NOTIFICATION_COLORS.Green
            elseif styleName == "Warning" then accent = NOTIFICATION_COLORS.Yellow
            elseif styleName == "Error" then accent = NOTIFICATION_COLORS.Red
            elseif styleName == "Info" then accent = palette.Accent
            else accent = NOTIFICATION_COLORS[notificationColor] or palette.Accent end
        end
        local accentUsesTheme = not (type(style) == "table" and typeof(style.Color) == "Color3")
            and styleName ~= "Success" and styleName ~= "Warning" and styleName ~= "Error"
            and (styleName == "Info" or notificationColor == "Theme")
        local roleOne = tostring(titleText or "?")
        local roleTwo = tostring(messageText or "?")
        local titleValue = roleReveal and translate("RoundRoles") or tostring(titleText or "Notice")
        local messageValue = roleReveal and "" or tostring(messageText or "")
        local toastWidth = 352
        local toastHeight = roleReveal and 98 or 68
        local top = notificationPosition:sub(1, 3) == "Top"
        local fromLeft = notificationPosition:sub(-4) == "Left"
        local fromRight = notificationPosition:sub(-5) == "Right"
        local slideX = fromLeft and -18 or (fromRight and 18 or 0)
        local slideY = (not fromLeft and not fromRight) and (top and -12 or 12) or 0
        local lifetime = math.max(tonumber(duration) or 3, 0.7)

        local slot = Instance.new("Frame")
        slot.Name = "NotificationSlot"
        slot.Parent = notificationHost
        slot.Size = UDim2.fromOffset(toastWidth, 0)
        slot.BackgroundTransparency = 1
        slot.BorderSizePixel = 0
        slot.LayoutOrder = top and -notificationOrder or notificationOrder
        slot.ZIndex = 2001

        local card = Instance.new("TextButton")
        card.Name = "NotificationCard"
        card.Parent = slot
        card.Position = UDim2.fromOffset(slideX, slideY)
        card.Size = UDim2.fromScale(1, 1)
        card.BackgroundColor3 = palette.Card
        card.BackgroundTransparency = 0.025
        card.BorderSizePixel = 0
        card.AutoButtonColor = false
        card.Text = ""
        card.ClipsDescendants = true
        card.ZIndex = 2002
        corner(card, 12)
        local cardStroke = stroke(card, accent, 0.22)
        setRole(card, "BackgroundColor3", "Card")
        if accentUsesTheme then setRole(cardStroke, "Color", "Accent") end
        local gradient = Instance.new("UIGradient")
        gradient.Name = "NotificationGradient"
        gradient.Color = ColorSequence.new(palette.White:Lerp(palette.Accent, 0.12), palette.White:Lerp(palette.Elev, 0.08))
        gradient.Rotation = 90
        gradient.Parent = card

        local dot = Instance.new("Frame")
        dot.Parent = card
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.Position = UDim2.fromOffset(19, 17)
        dot.Size = UDim2.fromOffset(6, 6)
        dot.BackgroundColor3 = accent
        dot.BorderSizePixel = 0
        dot.ZIndex = 2004
        corner(dot, 6)
        if accentUsesTheme then setRole(dot, "BackgroundColor3", "Accent") end

        local heading = newText(card, titleValue, 14, palette.White, Enum.Font.GothamBold)
        heading.Position = UDim2.fromOffset(31, 7)
        heading.Size = UDim2.new(1, -62, 0, 20)
        heading.TextTruncate = Enum.TextTruncate.AtEnd
        heading.ZIndex = 2004
        setRole(heading, "TextColor3", "White")
        if roleReveal then registerText(heading, "RoundRoles", false) end

        local closeGlyph = Instance.new("TextLabel")
        closeGlyph.Parent = card
        closeGlyph.AnchorPoint = Vector2.new(1, 0)
        closeGlyph.Position = UDim2.new(1, -13, 0, 7)
        closeGlyph.Size = UDim2.fromOffset(18, 18)
        closeGlyph.BackgroundTransparency = 1
        closeGlyph.Font = Enum.Font.GothamMedium
        closeGlyph.Text = "×"
        closeGlyph.TextColor3 = palette.White
        closeGlyph.TextTransparency = 0.18
        closeGlyph.TextSize = 14
        closeGlyph.ZIndex = 2004
        setRole(closeGlyph, "TextColor3", "White")

        if roleReveal then
            local function roleRow(rowName, y, roleName, value, color)
                local row = Instance.new("Frame")
                row.Name = rowName
                row.Parent = card
                row.Position = UDim2.fromOffset(17, y)
                row.Size = UDim2.new(1, -34, 0, 25)
                row.BackgroundColor3 = palette.Elev
                row.BackgroundTransparency = 0.12
                row.BorderSizePixel = 0
                row.ZIndex = 2003
                corner(row, 7)
                local rowStroke = stroke(row, palette.Bd, 0.38)
                setRole(row, "BackgroundColor3", "Elev")
                setRole(rowStroke, "Color", "Bd")
                local roleDot = Instance.new("Frame")
                roleDot.Parent = row
                roleDot.AnchorPoint = Vector2.new(0, 0.5)
                roleDot.Position = UDim2.fromOffset(10, 12)
                roleDot.Size = UDim2.fromOffset(6, 6)
                roleDot.BackgroundColor3 = color
                roleDot.BorderSizePixel = 0
                roleDot.ZIndex = 2005
                corner(roleDot, 6)
                local roleLabel = newText(row, roleName, 10, color, Enum.Font.GothamBold)
                roleLabel.Position = UDim2.fromOffset(24, 0)
                roleLabel.Size = UDim2.fromOffset(82, 25)
                roleLabel.ZIndex = 2005
                local playerLabel = newText(row, value, 13, palette.White, Enum.Font.GothamMedium)
                playerLabel.Position = UDim2.fromOffset(108, 0)
                playerLabel.Size = UDim2.new(1, -118, 1, 0)
                playerLabel.TextTruncate = Enum.TextTruncate.AtEnd
                playerLabel.TextXAlignment = Enum.TextXAlignment.Right
                playerLabel.ZIndex = 2005
                setRole(playerLabel, "TextColor3", "White")
            end
            roleRow("MurdererRole", 31, "MURDERER", roleOne, Color3.fromRGB(255,76,76))
            roleRow("SheriffRole", 60, "SHERIFF", roleTwo, Color3.fromRGB(224,224,220))
        else
            local bodyLabel = newText(card, messageValue, 13, palette.White, Enum.Font.GothamMedium)
            bodyLabel.Position = UDim2.fromOffset(19, 30)
            bodyLabel.Size = UDim2.new(1, -38, 0, 25)
            bodyLabel.TextWrapped = true
            bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
            bodyLabel.ZIndex = 2004
            setRole(bodyLabel, "TextColor3", "White")
        end

        local progressTrack = Instance.new("Frame")
        progressTrack.Parent = card
        progressTrack.AnchorPoint = Vector2.new(0, 1)
        progressTrack.Position = UDim2.new(0, 19, 1, -6)
        progressTrack.Size = UDim2.new(1, -38, 0, 2)
        progressTrack.BackgroundColor3 = palette.Bd2
        progressTrack.BackgroundTransparency = 0.25
        progressTrack.BorderSizePixel = 0
        progressTrack.ZIndex = 2003
        corner(progressTrack, 2)
        setRole(progressTrack, "BackgroundColor3", "Bd2")
        local progress = Instance.new("Frame")
        progress.Parent = progressTrack
        progress.Size = UDim2.fromScale(1, 1)
        progress.BackgroundColor3 = accent
        progress.BorderSizePixel = 0
        progress.ZIndex = 2004
        corner(progress, 2)
        if accentUsesTheme then setRole(progress, "BackgroundColor3", "Accent") end

        local entry = { Slot=slot, Order=notificationOrder }
        table.insert(notifications, entry)
        local closed = false
        local progressTween
        local function dismiss()
            if closed then return end
            closed = true
            if progressTween then pcall(function() progressTween:Cancel() end) end
            for index, current in ipairs(notifications) do
                if current == entry then table.remove(notifications, index); break end
            end
            if not slot.Parent then return end
            TweenService:Create(card, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.fromOffset(slideX, slideY), BackgroundTransparency = 1,
            }):Play()
            task.delay(0.11, function()
                if slot.Parent then
                    TweenService:Create(slot, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                        Size = UDim2.fromOffset(toastWidth, 0),
                    }):Play()
                end
            end)
            task.delay(0.31, function() if slot.Parent then slot:Destroy() end end)
        end
        entry.Dismiss = dismiss
        if #notifications > 4 and notifications[1] and notifications[1].Dismiss then notifications[1].Dismiss() end
        connect(card.Activated, dismiss)
        connect(card.MouseEnter, function()
            if closed then return end
            TweenService:Create(cardStroke, TweenInfo.new(0.12), { Transparency=0.02 }):Play()
            closeGlyph.TextTransparency = 0
        end)
        connect(card.MouseLeave, function()
            if closed then return end
            TweenService:Create(cardStroke, TweenInfo.new(0.12), { Transparency=0.14 }):Play()
            closeGlyph.TextTransparency = 0.18
        end)
        TweenService:Create(slot, TweenInfo.new(0.2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(toastWidth, toastHeight),
        }):Play()
        TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Position = UDim2.fromOffset(0, 0),
        }):Play()
        progressTween = TweenService:Create(progress, TweenInfo.new(lifetime, Enum.EasingStyle.Linear), {
            Size = UDim2.new(0, 0, 1, 0),
        })
        progressTween:Play()
        task.delay(lifetime, dismiss)
        return { Dismiss=dismiss, Frame=slot }
    end

    function api:NotifyRoundRoles(murdererName, sheriffName, duration)
        return api:Notify(murdererName or "?", sheriffName or "?", duration or 6, "RoundRoles")
    end

    function api:NotifyInfo(titleText, messageText, duration)
        return api:Notify(titleText, messageText, duration, "Info")
    end

    function api:NotifySuccess(titleText, messageText, duration)
        return api:Notify(titleText, messageText, duration, "Success")
    end

    function api:NotifyWarning(titleText, messageText, duration)
        return api:Notify(titleText, messageText, duration, "Warning")
    end

    function api:NotifyError(titleText, messageText, duration)
        return api:Notify(titleText, messageText, duration, "Error")
    end

    function api:NotifyCustom(titleText, messageText, color, duration)
        return api:Notify(titleText, messageText, duration, { Kind="Custom", Color=color })
    end

    function api:SetVisible(visible)
        main.Visible = visible == true
    end

    function api:SetProfile(profileTitle, profileSubtitle, profileAvatar)
        title.Text = tostring(profileTitle or "INERTIA")
        subtitle.Text = tostring(profileSubtitle or "UI ONLY MODULE")
        if profileAvatar ~= nil then avatar.Image = tostring(profileAvatar) end
    end

    function api:SetAvatar(value)
        if value ~= nil then avatar.Image = tostring(value) end
    end

    function api:SetExecutor(value)
        executorValue.Text = tostring(value or "Unknown")
    end

    function api:SetSettingsVisible(visible)
        settingsModal.Visible = visible == true
    end

    function api:ApplySettings(values)
        if type(values) ~= "table" then return false end
        if values.Theme then api:SetTheme(values.Theme) end
        if values.Language then api:SetLanguage(values.Language) end
        if values.TextScale then api:SetTextScale(values.TextScale) end
        if values.HUDScale then api:SetHUDScale(values.HUDScale) end
        if values.NotificationPosition then api:SetNotificationPosition(values.NotificationPosition) end
        if values.NotificationColor then api:SetNotificationColor(values.NotificationColor) end
        return true
    end

    connect(close.Activated, function() main.Visible = false end)
    connect(search:GetPropertyChangedSignal("Text"), function()
        local query = string.lower(search.Text or "")
        for _, control in pairs(controls) do
            local row = control.Row
            row.Visible = query == "" or string.find(string.lower(row.Name), query, 1, true) ~= nil
        end
    end)

    if options.CreateDefaultPages ~= false then
        for _, pageName in ipairs({"Visuals", "Combat", "Motion", "Player", "Misc", "Teleport", "Servers", "Config"}) do
            if not pages[pageName] then api:AddPage(pageName) end
        end
    end

    if options.CreateHUD ~= false then
        api.HUD = api:CreateHUDSuite(options.HUD)
    end

    function api:Destroy()
        for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
        connections = {}
        if root then root:Destroy() end
    end

    function api:GetRoot() return root end
    function api:GetPages() return pages end
    function api:GetHUD() return huds end
    function api:GetState()
        return {
            Theme=themeName,
            Language=language,
            TextScale=textScale,
            HUDScale=hudScale,
            NotificationPosition=notificationPosition,
            NotificationColor=notificationColor,
        }
    end

    styleTree()
    return api
end

HUD.Themes = THEMES
HUD.Locales = LOCALES
return HUD
