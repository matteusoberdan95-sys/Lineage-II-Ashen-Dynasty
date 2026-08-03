package ai.others.AshenProgressionHub;

import java.util.Map;

import org.l2jmobius.gameserver.data.xml.ExperienceData;
import org.l2jmobius.gameserver.data.xml.SkillData;
import org.l2jmobius.gameserver.model.item.enums.ItemProcessType;
import org.l2jmobius.gameserver.model.Location;
import org.l2jmobius.gameserver.model.actor.Npc;
import org.l2jmobius.gameserver.model.actor.Player;
import org.l2jmobius.gameserver.model.script.Script;
import org.l2jmobius.gameserver.model.skill.Skill;

/**
 * Ashen Dynasty progression hub (Fase 10: official minimum baseline).
 */
public class AshenProgressionHub extends Script
{
	private static final int GM_SHOP = 93010;
	private static final int BUFFER = 93011;
	private static final int GATEKEEPER = 93012;
	private static final int PROGRESSION_SHOP = 93013;
	private static final int SERVICE_MANAGER = 93014;
	
	private static final Map<String, Location> TELEPORTS = Map.ofEntries(
		// Official Interlude city destinations.
		Map.entry("city_talking_island", new Location(-84119, 243254, -3730)),
		Map.entry("city_gludin", new Location(-82032, 150160, -3127)),
		Map.entry("city_gludio", new Location(-14048, 123184, -3120)),
		Map.entry("city_dion", new Location(15670, 142983, -2705)),
		Map.entry("city_giran", new Location(83400, 147943, -3404)),
		Map.entry("city_oren", new Location(82956, 53162, -1495)),
		Map.entry("city_aden", new Location(146331, 25762, -2018)),
		Map.entry("city_rune", new Location(43835, -47749, -792)),
		Map.entry("city_goddard", new Location(147930, -55281, -2728)),
		Map.entry("area_ant_nest", new Location(-32636, 122938, -3713)),
		Map.entry("area_toi", new Location(114679, 13436, -5101)),
		Map.entry("hub", new Location(83550, 148250, -3404))
	);
	
	private static final int[] HUB_NPCS =
	{
		GM_SHOP,
		BUFFER,
		GATEKEEPER,
		PROGRESSION_SHOP,
		SERVICE_MANAGER
	};
	
	public AshenProgressionHub()
	{
		addStartNpc(HUB_NPCS);
		addTalkId(HUB_NPCS);
		addFirstTalkId(HUB_NPCS);
	}
	
	@Override
	public String onFirstTalk(Npc npc, Player player)
	{
		switch (npc.getId())
		{
			case GM_SHOP:
			{
				return "93010.htm";
			}
			case BUFFER:
			{
				return "93011.htm";
			}
			case GATEKEEPER:
			{
				return "93012.htm";
			}
			case PROGRESSION_SHOP:
			{
				return "93013.htm";
			}
			case SERVICE_MANAGER:
			{
				return "93014.htm";
			}
		}
		return null;
	}
	
	@Override
	public String onEvent(String event, Npc npc, Player player)
	{
		if (event.equals("buff_fighter"))
		{
			applySkill(player, 1204, 2); // Wind Walk
			applySkill(player, 1040, 3); // Shield
			applySkill(player, 1068, 3); // Might
			applySkill(player, 1086, 2); // Haste
			applySkill(player, 1077, 3); // Focus
			applySkill(player, 1242, 3); // Death Whisper
			player.sendMessage("Ashen Buffer: fighter buff pack applied.");
			return "93011.htm";
		}
		if (event.equals("buff_mage"))
		{
			applySkill(player, 1204, 2); // Wind Walk
			applySkill(player, 1040, 3); // Shield
			applySkill(player, 1085, 3); // Acumen
			applySkill(player, 1059, 3); // Empower
			applySkill(player, 1078, 6); // Concentration
			player.sendMessage("Ashen Buffer: mage buff pack applied.");
			return "93011.htm";
		}
		if (event.equals("restore_hp"))
		{
			player.setCurrentHp(player.getMaxHp());
			return "93011.htm";
		}
		if (event.equals("restore_cp"))
		{
			player.setCurrentCp(player.getMaxCp());
			return "93011.htm";
		}
		if (event.equals("restore_mp"))
		{
			player.setCurrentMp(player.getMaxMp());
			return "93011.htm";
		}
		if (event.equals("cancel_buffs"))
		{
			player.stopAllEffects();
			return "93011.htm";
		}
		if (event.equals("test_heal_all"))
		{
			player.setCurrentHp(player.getMaxHp());
			player.setCurrentCp(player.getMaxCp());
			player.setCurrentMp(player.getMaxMp());
			player.sendMessage("Ashen Services TEST_ONLY: HP/CP/MP restored.");
			return "93014.htm";
		}
		if (event.equals("test_cancel_buffs"))
		{
			player.stopAllEffects();
			player.sendMessage("Ashen Services TEST_ONLY: all buffs removed.");
			return "93014.htm";
		}
		if (event.equals("test_add_adena_1m"))
		{
			player.addAdena(ItemProcessType.REWARD, 1_000_000, npc, true);
			player.sendMessage("Ashen Services TEST_ONLY: 1,000,000 adena granted.");
			return "93014.htm";
		}
		if (event.equals("test_set_level_76"))
		{
			setLevelForTest(player, (byte) 76);
			player.sendMessage("Ashen Services TEST_ONLY: level adjusted to 76.");
			return "93014.htm";
		}
		if (event.startsWith("tele_"))
		{
			final String key = event.substring(5);
			final Location target = TELEPORTS.get(key);
			if (target != null)
			{
				player.teleToLocation(target);
				player.sendMessage("Ashen Gatekeeper: teleportado para " + key + ".");
			}
			return "93012.htm";
		}
		return null;
	}
	
	private void applySkill(Player player, int skillId, int level)
	{
		final Skill skill = SkillData.getInstance().getSkill(skillId, level);
		if (skill != null)
		{
			skill.applyEffects(player, player);
		}
	}

	private void setLevelForTest(Player player, byte targetLevel)
	{
		final long playerExp = player.getExp();
		final long targetExp = ExperienceData.getInstance().getExpForLevel(targetLevel);
		if (playerExp > targetExp)
		{
			player.removeExpAndSp(playerExp - targetExp, 0);
		}
		else if (playerExp < targetExp)
		{
			player.addExpAndSp(targetExp - playerExp, 0);
		}
		player.setCurrentHp(player.getMaxHp());
		player.setCurrentCp(player.getMaxCp());
		player.setCurrentMp(player.getMaxMp());
		player.broadcastUserInfo();
	}
	
	public static void main(String[] args)
	{
		new AshenProgressionHub();
	}
}
