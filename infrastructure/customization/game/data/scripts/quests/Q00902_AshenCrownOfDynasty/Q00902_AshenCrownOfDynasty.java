/*
 * Ashen Dynasty — Sprint 23
 * Transition quest DK/Phoenix -> Dynarty (token/recipe reward, not a full set).
 */
package quests.Q00902_AshenCrownOfDynasty;

import org.l2jmobius.gameserver.model.actor.Npc;
import org.l2jmobius.gameserver.model.actor.Player;
import org.l2jmobius.gameserver.model.script.Quest;
import org.l2jmobius.gameserver.model.script.QuestState;
import org.l2jmobius.gameserver.model.script.State;

import quests.Q00901_AshenEmberOfAscent.Q00901_AshenEmberOfAscent;

/**
 * One-time bridge after Ashen DK/Phoenix farming: exchange DK fragments for
 * Dynarty fragments + one key craft recipe (ADR-008 / ADR-010).
 */
public class Q00902_AshenCrownOfDynasty extends Quest
{
	private static final int CHRONICLER = 93002;
	private static final int DK_FRAGMENT = 9699;
	private static final int DYNARTY_FRAGMENT = 9799;
	private static final int RECIPE_DYNARTY_BREASTPLATE = 9573;
	private static final int REQUIRED_DK_FRAGMENTS = 25;
	private static final int REWARD_DYNARTY_FRAGMENTS = 12;
	private static final int MIN_LEVEL = 80;
	
	public Q00902_AshenCrownOfDynasty()
	{
		super(902, "Ashen Crown of Dynasty");
		setCustom(true);
		addStartNpc(CHRONICLER);
		addTalkId(CHRONICLER);
	}
	
	private static boolean hasCompletedEmberQuest(Player player)
	{
		final QuestState prev = player.getQuestState(Q00901_AshenEmberOfAscent.class.getSimpleName());
		return (prev != null) && prev.isCompleted();
	}
	
	@Override
	public String onEvent(String event, Npc npc, Player player)
	{
		final QuestState st = getQuestState(player, false);
		if (st == null)
		{
			return null;
		}
		
		switch (event)
		{
			case "93002-02.htm":
			{
				if (!hasCompletedEmberQuest(player) || (player.getLevel() < MIN_LEVEL))
				{
					return "93002-00.htm";
				}
				st.startQuest();
				break;
			}
			case "93002-05.htm":
			{
				if (!st.isCond(1))
				{
					return event;
				}
				if (getQuestItemsCount(player, DK_FRAGMENT) < REQUIRED_DK_FRAGMENTS)
				{
					return "93002-03.htm";
				}
				
				takeItems(player, DK_FRAGMENT, REQUIRED_DK_FRAGMENTS);
				giveItems(player, DYNARTY_FRAGMENT, REWARD_DYNARTY_FRAGMENTS);
				giveItems(player, RECIPE_DYNARTY_BREASTPLATE, 1);
				st.exitQuest(false, true);
				break;
			}
		}
		
		return event;
	}
	
	@Override
	public String onTalk(Npc npc, Player player)
	{
		final QuestState st = getQuestState(player, true);
		String htmltext = getNoQuestMsg(player);
		
		switch (st.getState())
		{
			case State.CREATED:
			{
				if ((player.getLevel() < MIN_LEVEL) || !hasCompletedEmberQuest(player))
				{
					htmltext = "93002-00.htm";
				}
				else
				{
					htmltext = "93002-01.htm";
				}
				break;
			}
			case State.STARTED:
			{
				htmltext = (getQuestItemsCount(player, DK_FRAGMENT) < REQUIRED_DK_FRAGMENTS) ? "93002-03.htm" : "93002-04.htm";
				break;
			}
			case State.COMPLETED:
			{
				htmltext = getAlreadyCompletedMsg(player);
				break;
			}
		}
		
		return htmltext;
	}
	
	public static void main(String[] args)
	{
		new Q00902_AshenCrownOfDynasty();
	}
}
