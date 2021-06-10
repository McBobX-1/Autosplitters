state("Astalon") {}

startup {
	print("--[Autosplitter] Starting up!--");
	refreshRate = 2;
	
	settings.Add("bosses", true, "---Bosses---");
	settings.Add("Tauros", true, "Tauros (Red)", "bosses");
	settings.Add("Volantis", true, "Volantis (Blue)", "bosses");
	settings.Add("Gemini", true, "Gemini (Basement)", "bosses");
	settings.Add("Solaria", true, "Solaria (Green)", "bosses");
	settings.Add("Medusa", true, "Medusa (Final)", "bosses");
	
	settings.Add("items", true, "---Items---");
	settings.Add("AmuletOfSol", false, "AmuletOfSol", "items");
	settings.Add("BanishSpell", false, "BanishSpell", "items");
	settings.Add("GorgonHeart", false, "GorgonHeart", "items");
	settings.Add("GriffonClaw", false, "GriffonClaw", "items");
	settings.Add("IcarusEmblem", false, "IcarusEmblem", "items");
	settings.Add("LunarianBow", false, "LunarianBow", "items");
	settings.Add("RingOfTheAncients", false, "RingOfTheAncients", "items");
	settings.Add("SwordOfMirrors", false, "SwordOfMirrors", "items");
	settings.Add("LunariaSword", false, "LunariaSword", "items");
	settings.Add("GorgonEyeRed", false, "GorgonEyeRed", "items");
	settings.Add("GorgonEyeBlue", false, "GorgonEyeBlue", "items");
	settings.Add("GorgonEyeGreen", false, "GorgonEyeGreen", "items");
	settings.Add("DeadMaidensRing", false, "DeadMaidensRing", "items");
	settings.Add("LinusMap", false, "LinusMap", "items");
	settings.Add("AthenasBell", false, "AthenasBell", "items");
	settings.Add("VoidCharm", false, "VoidCharm", "items");
	settings.Add("TomeOfTongues", false, "TomeOfTongues", "items");
	settings.Add("CloakOfLevitation", false, "CloakOfLevitation", "items");
	settings.Add("MarkOfEpimetheus", false, "MarkOfEpimetheus", "items");
	settings.Add("AdornedKey", false, "AdornedKey", "items");
	settings.Add("CrackedBell", false, "CrackedBell", "items");
	settings.Add("CeremonialDagger", false, "CeremonialDagger", "items");
	settings.Add("CrystalFragment", false, "CrystalFragment", "items");
	settings.Add("GoldChalice", false, "GoldChalice", "items");
	settings.Add("PrincesCrown", false, "PrincesCrown", "items");
	settings.Add("SkeletonIdol", false, "SkeletonIdol", "items");
	settings.Add("ZeekItem", false, "ZeekItem", "items");
	settings.Add("AscendantKey", false, "AscendantKey", "items");
	settings.Add("TalariaBoots", false, "TalariaBoots", "items");
	settings.Add("MonsterBall", false, "MonsterBall", "items");
	settings.Add("BloodChalice", false, "BloodChalice", "items");
	settings.Add("MorningStar", false, "MorningStar", "items");
	settings.Add("CyclopsIdol", false, "CyclopsIdol", "items");
	settings.Add("BoreasGauntlet", false, "BoreasGauntlet", "items");
	settings.Add("FamiliarGil", false, "FamiliarGil", "items");
	settings.Add("Bestiary", false, "Bestiary", "items");
	settings.Add("Music", false, "Music", "items");
	settings.Add("BiggerLoot", false, "BiggerLoot", "items");
	settings.Add("MagicBlock", false, "MagicBlock", "items");
	
	settings.Add("elevators", true, "---Elevators---");
	settings.Add("testele", false, "TestEle", "elevators");
	
	settings.Add("location", true, "---Location Based Events---");
	settings.Add("testloc", false, "TestLoc", "location");
	
	settings.Add("infosection", true, "---Info---");
	settings.Add("info", true, "Astalon Autosplitter v1.2 by Coltaho", "infosection");
	settings.Add("info0", true, "Supports Astalon v1.0+", "infosection");
	settings.Add("info1", true, "- Website : https://github.com/Coltaho/Autosplitters", "infosection");
	
	vars.timer_OnStart = (EventHandler)((s, e) =>
    {
        vars.bosswatchers.ResetAll();
		vars.medusakilled = false;
    });
    timer.OnStart += vars.timer_OnStart;
}

init {	
	vars.scanTarget = new SigScanTarget(0, "A1 ???????? 83 C4 08 8B 40 5C 8B 00 85 C0 0F84 ???????? 8B 40 10 85 C0 0F84 ???????? 6A 00 50 E8 ???????? 83 C4 08 A1 ???????? 8B 40 5C 8B 30");
	
	var mymodule = modules.Where(m => m.ModuleName == "GameAssembly.dll").First();
	vars.sigAddr = IntPtr.Zero;
	var scanner = new SignatureScanner(game, mymodule.BaseAddress, mymodule.ModuleMemorySize);
	vars.sigAddr = scanner.Scan(vars.scanTarget);
	
	if (vars.sigAddr == IntPtr.Zero)
		throw new Exception("--Couldn't find a pointer I want! Game is still starting or an update broke things!");
	
	print("--[Autosplitter] Sig scan addr: " + ((int)vars.sigAddr).ToString("X"));
	
	vars.watchers = new MemoryWatcherList();
	vars.watchers.Add(new MemoryWatcher<bool>(new DeepPointer(vars.sigAddr + 0x1, 0x0, 0x5C, 0x0, 0x10, 0xC)) { Name = "mainMenuOpen" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.sigAddr + 0x2C, 0x0, 0x5C, 0x0, 0x28, 0x144, 0x94)) { Name = "igt" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.sigAddr + 0x2C, 0x0, 0x5C, 0x0, 0x28, 0x144, 0xA0)) { Name = "currentRoom" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.sigAddr + 0x2C, 0x0, 0x5C, 0x0, 0x28, 0x144, 0xC8, 0xC)) { Name = "defeatedBosses_size" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.sigAddr + 0x2C, 0x0, 0x5C, 0x0, 0x28, 0x144, 0xC4, 0xC)) { Name = "elevatorsFound_size" });
	vars.watchers.Add(new MemoryWatcher<int>(new DeepPointer(vars.sigAddr + 0x2C, 0x0, 0x5C, 0x0, 0x28, 0x144, 0xF0, 0xC)) { Name = "collectedItems_size" });
	
	
	
	vars.ItemObtained = (Func<int, bool>)((value) =>
	{		
		if (vars.watchers["collectedItems_size"].Old != vars.watchers["collectedItems_size"].Current) {
			for (int i = 0; i < vars.watchers["collectedItems_size"].Current; i++) {
				var itemoffset = 0x10 + i * 0x4;
				var itemID = new DeepPointer(vars.sigAddr + 0x2C, 0x0, 0x5C, 0x0, 0x28, 0x144, 0xF0, 0x8, itemoffset).Deref<int>(game);
				if (itemID == value) {
					return true;
				}
			}
		}
		return false;
	});
	
	vars.Killed = (Func<string, bool>)((value) =>
	{
		if (vars.watchers["defeatedBosses_size"].Old != vars.watchers["defeatedBosses_size"].Current) {
			for (int i = 0; i < vars.watchers["defeatedBosses_size"].Current; i++) {
				var itemoffset = 0x10 + i * 0x4;
				var boss = new DeepPointer(vars.sigAddr + 0x2C, 0x0, 0x5C, 0x0, 0x28, 0x144, 0xC8, 0x8, itemoffset, 0xC).DerefString(game, 16);				
				if (boss == value && value == "Medusa") {
					vars.medusakilled = true;
					return false;
				}
				if (boss == value)
					return true;
			}
		}
		return false;
	});
	
	vars.Transitioned = (Func<int, int, bool>)((prev, value) =>
	{
		return vars.watchers["currentRoom"].Current == prev && vars.watchers["currentRoom"].Current == value;
	});
	
	vars.GetSplitList = (Func<Dictionary<string, bool>>)(() =>
	{
		var splits = new Dictionary<string, bool>
		{
			// Bosses
			{ "Tauros", vars.Killed("Tauros") },
			{ "Volantis", vars.Killed("Volantis") },
			{ "Gemini", vars.Killed("Gemini") },
			{ "Solaria", vars.Killed("Solaria") },
			{ "Medusa", vars.Killed("Medusa") },
			
			// Items
			{ "AmuletOfSol", vars.ItemObtained(0) },
			{ "BanishSpell", vars.ItemObtained(1) },
			{ "GorgonHeart", vars.ItemObtained(2) },
			{ "GriffonClaw", vars.ItemObtained(3) },
			{ "IcarusEmblem", vars.ItemObtained(4) },
			{ "LunarianBow", vars.ItemObtained(5) },
			{ "RingOfTheAncients", vars.ItemObtained(6) },
			{ "SwordOfMirrors", vars.ItemObtained(7) },
			{ "LunariaSword", vars.ItemObtained(8) },
			{ "GorgonEyeRed", vars.ItemObtained(9) },
			{ "GorgonEyeBlue", vars.ItemObtained(10) },
			{ "GorgonEyeGreen", vars.ItemObtained(11) },
			{ "DeadMaidensRing", vars.ItemObtained(12) },
			{ "LinusMap", vars.ItemObtained(13) },
			{ "AthenasBell", vars.ItemObtained(14) },
			{ "VoidCharm", vars.ItemObtained(15) },
			{ "TomeOfTongues", vars.ItemObtained(16) },
			{ "CloakOfLevitation", vars.ItemObtained(18) },
			{ "MarkOfEpimetheus", vars.ItemObtained(19) },
			{ "AdornedKey", vars.ItemObtained(20) },
			{ "CrackedBell", vars.ItemObtained(21) },
			{ "CeremonialDagger", vars.ItemObtained(22) },
			{ "CrystalFragment", vars.ItemObtained(23) },
			{ "GoldChalice", vars.ItemObtained(24) },
			{ "PrincesCrown", vars.ItemObtained(25) },
			{ "SkeletonIdol", vars.ItemObtained(26) },
			{ "ZeekItem", vars.ItemObtained(27) },
			{ "AscendantKey", vars.ItemObtained(28) },
			{ "TalariaBoots", vars.ItemObtained(29) },
			{ "MonsterBall", vars.ItemObtained(34) },
			{ "BloodChalice", vars.ItemObtained(35) },
			{ "MorningStar", vars.ItemObtained(36) },
			{ "CyclopsIdol", vars.ItemObtained(37) },
			{ "BoreasGauntlet", vars.ItemObtained(39) },
			{ "FamiliarGil", vars.ItemObtained(40) },
			{ "Bestiary", vars.ItemObtained(41) },
			{ "Music", vars.ItemObtained(42) },
			{ "BiggerLoot", vars.ItemObtained(43) },
			{ "MagicBlock", vars.ItemObtained(44) },
			
		};
		return splits;
	});
	
	vars.pastSplits = new HashSet<string>();
	vars.medusakilled = false;
	vars.mystring = "";
	vars.paststring = "";
	refreshRate = 60;
}

update {
	if (timer.CurrentPhase == TimerPhase.NotRunning && vars.pastSplits.Count > 0)
		vars.pastSplits.Clear();
	
	vars.watchers.UpdateAll(game);

	// vars.mystring = "--MainMenuOpen: " + vars.watchers["mainMenuOpen"].Current + " | IGT: " + vars.watchers["igt"].Current + " | CurrentRoom: " + vars.watchers["currentRoom"].Current + " | defeatedBosses: " + vars.watchers["defeatedBosses_size"].Current;
	// if (vars.paststring != vars.mystring) {
		// print(vars.mystring);
		// vars.paststring = vars.mystring;
	// }
}

start {
	if(vars.watchers["igt"].Old == 0 && vars.watchers["igt"].Current == 1) {
		return true;
	}
}

reset {
	return (vars.watchers["mainMenuOpen"].Current);
}

split {

	if (vars.medusakilled == true && vars.watchers["igt"].Old != vars.watchers["igt"].Current) {
		print("--[Autosplitter] Split: Medusa");
		vars.medusakilled = false;
		return true;
	}
	
	var splits = vars.GetSplitList();

	foreach (var split in splits)
	{
		if (settings[split.Key] && split.Value && !vars.pastSplits.Contains(split.Key))
		{
			vars.pastSplits.Add(split.Key);
			print("--[Autosplitter] Split: " + split.Key);
			return true;
		}
	}
}

isLoading {
	return true;
}

gameTime {
	return TimeSpan.FromSeconds(vars.watchers["igt"].Current);
}

shutdown {
	timer.OnStart -= vars.timer_OnStart;
}
