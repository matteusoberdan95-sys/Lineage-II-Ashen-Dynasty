/*
 * Ashen Dynasty — Sprint 20
 * Transition quest Draconic -> DK/Phoenix (token/recipe reward, not a full set).
 */
package quests.Q00901_AshenEmberOfAscent;

import org.l2jmobius.gameserver.model.actor.Npc;
import org.l2jmobius.gameserver.model.actor.Player;
import org.l2jmobius.gameserver.model.script.Quest;
import org.l2jmobius.gameserver.model.script.QuestState;
import org.l2jmobius.gameserver.model.script.State;

import quests.Q00900_AshenScaleOfTransition.Q00900_AshenScaleOfTransition;

/**
 * One-time bridge after Ashen Draconic farming: exchange Draconic fragments for
 * DK fragments + one key craft recipe (ADR-008 / ADR-009).
 */
public class Q00901_AshenEmberOfAscent extends Quest
{
	private static final int CHRONICLER = 93002;
	private static final int DRACONIC_FRAGMENT = 9499;
	private static final int DK_FRAGMENT = 9699;
	private static final int RECIPE_DK_BREASTPLATE = 9547;
	private static final int REQUIRED_DRACONIC_FRAGMENTS = 20;
	private static final int REWARD_DK_FRAGMENTS = 12;
	private static final int MIN_LEVEL = 78;
	
	public Q00901_AshenEmberOfAscent()
	{
		super(901, "Ashen Ember of Ascent");
		setCustom(true);
		addStartNpc(CHRONICLER);
		addTalkId(CHRONICLER);
	}
	
	private static boolean hasCompletedScaleQuest(Player player)
	{
		final QuestState prev = player.getQuestState(Q00900_AshenScaleOfTransition.class.getSimpleName());
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
				if (!hasCompletedScaleQuest(player) || (player.getLevel() < MIN_LEVEL))
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
				if (getQuestItemsCount(player, DRACONIC_FRAGMENT) < REQUIRED_DRACONIC_FRAGMENTS)
				{
					return "93002-03.htm";
				}
				
				takeItems(player, DRACONIC_FRAGMENT, REQUIRED_DRACONIC_FRAGMENTS);
				giveItems(player, DK_FRAGMENT, REWARD_DK_FRAGMENTS);
				giveItems(player, RECIPE_DK_BREASTPLATE, 1);
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
				if ((player.getLevel() < MIN_LEVEL) || !hasCompletedScaleQuest(player))
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
				htmltext = (getQuestItemsCount(player, DRACONIC_FRAGMENT) < REQUIRED_DRACONIC_FRAGMENTS) ? "93002-03.htm" : "93002-04.htm";
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
		new Q00901_AshenEmberOfAscent();
	}
}
