/**
 * @author Christian Pautsch
 * @file BlackJackDemo
 * This is a simplified version of a game of Blackjack. It sets up a
 * simple, two-person (player and dealer) game of Blackjack. After dealing
 * out two cards and evaluating win conditions, it allows the player to hit until
 * they are satisfied and choose to stand. The dealer will hit as long as they are
 * under a soft 17. The game will then evaluate the final results. Note that the
 * Player and Deck classes could be adapted for a variety of card games.
 */

import java.util.*;
import java.util.Scanner;
import java.util.Arrays;
import java.io.*;
import java.util.concurrent.ThreadLocalRandom;

/**
* Main method to test BlackJackGame class. Creates a BlackJackGame
* object, then starts the game using the playGame() method.
*/
public class BlackJackDemo
{
	public static void main(String args[]) throws IOException
	{
	// creates game
	BlackJackGame demoGame = new BlackJackGame();

	// starts game
	demoGame.playGame();
	}	// end main
   
}	// end BlackJackDemo

//==================================================================================

/**
 * An application class for a simplified game of BlackJack. Sets up a
 * two-person game of blackjack, deals cards, evaluates win conditions,
 * then allows user (player) to hit or stand. Dealer then automatically
 * hits until they reach 17 points or more. Various functions of game are split
 * into distinct methods. Currently set up for only two players, but it could
 * be modified to handle more. The only public method is playGame, as the
 * rest of the game is automated.
 */
class BlackJackGame
{
	/**
	 * Player object representing Player 1.
	 */
	private Player player1;
	
	/**
	 * Player object representing the Dealer.
	 */
	private Player dealer;
	
	/**
	 * Deck object representing the deck of cards.
	 */
	private Deck cardDeck;
	
	/**
	 * Boolean value representing the end of the game. True if game is over, false if not.
	 */
	private Boolean endGame;
	
	/**
	 * Integer constant representing an ID for player 1, used for displaying player card totals.
	 */
	private final int PLAYER1_ID = 1;
	
	/**
	 * Integer constant representing an ID for the dealer, used for displaying card totals. Arbitrarily set to 9 to allow for expansion of players.
	 */
	private final int DEALER_ID = 9;
	
	/**
	 * Integer constant representing the maximum score in Blackjack.
	 */
	public static final int BUST_SCORE = 21;
	
	/**
	 * Integer constant representing the soft score for dealers in Blackjack.
	 */
	public final int SOFT_DEALER = 17;
	
	/**
	 * Default constructor. Creates Player and Deck objects and sets endGame to false.
	 */
	public BlackJackGame()
	{
		player1 = new Player();
		dealer = new Player();
		cardDeck = new Deck();
		endGame = false;
	} // end constructor
	
	/**
	 * playGame method. Starts the game of BlackJack. Sets up the initial parameters of
	 * the game (2 cards per player), then begins the Player turns, followed by Dealer turns.
	 * A final win evaluation is called after the last turn is taken, if a winner has not been
	 * decided already.
	 */
	public void playGame()
	{
		System.out.println("Welcome to BlackJack! \n");
		
		// Boolean value to tell evaluateWin() method when the final win evaluation must be made
		boolean finalCheck = false;
		
		cardDeck.getDeck();
		
		System.out.println("Dealing cards...");
		
		// Each player gets 2 cards to start
		player1.hit( cardDeck.draw() );
		player1.hit( cardDeck.draw() );
		dealer.hit( cardDeck.draw() );
		dealer.hit( cardDeck.draw() );
		
		// displays current cards
		displayPlayerCards(PLAYER1_ID);
		displayPlayerCards(DEALER_ID);
		
		// checks for win
		evaluateWin(finalCheck);
		
		// begins player1 turns
		playerTurns();
		
		// begins dealer turns
		dealerTurns();
		
		// instructs evaluateWin to make final victory check
		finalCheck = true;
		evaluateWin(finalCheck);
		
		// Cleans up objects
		cardDeck.newDeck();
		player1.resetHand();
		dealer.resetHand();
	} // end playGame
	
	/**
	 * Method for conducting player turns. When called, prompts user (player1) to either hit or stand.
	 * If they hit, a new card is drawn. If they stand, their turn is over.
	 */
	private void playerTurns()
	{
		// Setting up user input
		Scanner key = new Scanner(System.in);
		String choice = "";
		
		// continues turn until win/loss or player chooses to stand
		while ( !player1.getStand() && !endGame )
		{
			// Promps user for input
			System.out.println("Do you wish to hit or stand? (1 = Hit, 2 = Stand)");
			
			// Accepts user input as string
			choice = key.nextLine();
			
			// Only accepts input of 1 or 2
			if (choice.equals("1"))
			{
				// adds card to player1 hand from cardDeck object
				System.out.println("Hitting...");
				player1.hit( cardDeck.draw() );
			}
			else if (choice.equals("2"))
			{
				System.out.println("Passing...");
				player1.stand();
			}
			else
			{
				System.out.println("That input was not recognized.");
			}
			
			// displays current player hand
			displayPlayerCards(PLAYER1_ID);
			
			// evaluates win conditions
			evaluateWin(false);
		} // end while
	} // end playerTurns
	
	/**
	 * Method for conducting dealer turns. When called, dealer will automatically
	 * hit as long as their total score is below 17, and then stand once they break that
	 * threshold. If they hit, a new card is drawn. If they stand, their turn is over.
	 */
	private void dealerTurns()
	{
		// loops until dealer stands or wins/loses
		while ( !dealer.getStand() && !endGame )
		{
			// checks total score of dealer's hand
			if ( dealer.getTotal() < 17)
			{
				// adds card to dealer hand from cardDeck
				dealer.hit( cardDeck.draw() );
				
				// displays current dealer hand
				displayPlayerCards(DEALER_ID);
				
				// evaluates victory conditions
				evaluateWin(false);
			}
			else
			{
				/* Dealer stands if they reach or already have 17 points in their hand.
				No evaluation is called, because this will be handled by the final victory check. */
				dealer.stand();
			} // end if else
		} // end while
	} // end dealerTurns
	
	/**
	 * Displays the point total and individuals cards for a players hand. Which player it displays
	 * is dependent upon the playerID that is passed to it. Constants are used to ensure correct
	 * identification and value is passed. Can be expanded for more players if necessary.
	 * @param playerID the ID of a player, expressed as an integer, to print information for
	 */
	public void displayPlayerCards(int playerID)
	{
		// checks for two distinct IDs. If, for some reason, the wrong value has been passed, then nothing will print
		if (playerID == PLAYER1_ID)
		{
			// Displays player, point total, and the individual cards in hand, using methods in player1 object
			System.out.println("Player (" + player1.getTotal() + "):\t" + player1.getCards() );
		}
		else if (playerID == DEALER_ID)
		{
			// Displays dealer, point total, and the individual cards in hand, using methods in dealer object
			System.out.println("Dealer (" + dealer.getTotal()  + "):\t" + dealer.getCards() );
		} // end if else
	} // end displayPlayerCards
	
	/**
	 * Evaluates win/loss for players. Checks all possible victory and defeat conditions for both player and
	 * dealer. If the finalCheck parameter is true, a second version is called, to be used only at the very end
	 * of the game after the dealer has finished their turn.
	 * @param finalCheck boolean value indicating if final check has been reached, true if yes, false if not
	 */
	private void evaluateWin(boolean finalCheck)
	{
		// Stores player and dealer scores in local variables, rather than repeatedly call the get methods
		int scoreP = player1.getTotal();
		int scoreD = dealer.getTotal();
		
		// first check: is the game still going? If it has ended, then no evaluation needs to be made
		if ( !endGame )
		{
			/* second check: is this the final evaluation? if not, the first block of statements executes.
			If Player == 21 and Dealer == 21, Tie
			If Player == 21 and Dealer != 21, Player wins
			If Player != 21 and Dealer == 21, Dealer wins
			If Player > 21, Dealer wins at any number
			If Player > Dealer at the end of the game and no one has busted or hit 21, Player wins
			The last check is performed only if finalCheck is true.
			*/
			if ( !finalCheck )
			{
				if (scoreP > BUST_SCORE)
				{
					System.out.println("You lose...");
					endGame = true;
				}
				else if (scoreP == BUST_SCORE)
				{
					if (scoreD == BUST_SCORE)
					{
						System.out.println("It's a tie.");
						endGame = true;
					}
					else
					{
						System.out.println("You win!");
						endGame = true;
					}
				} // end scoreP > BUST_SCORE
				else
				{
					if (scoreD == BUST_SCORE)
					{
						System.out.println("You lose...");
						endGame = true;
					}
					else if (scoreD > BUST_SCORE)
					{
						System.out.println("You win!");
						endGame = true;
					}
				} // end ScoreP <= BUST SCORE
			} // end finalCheck = false
			else
			{
				// Final victory condition check
				if ( dealer.getTotal() < player1.getTotal() )
				{
					System.out.println("You win!");
				}
				else if ( dealer.getTotal() == player1.getTotal() )
				{
					System.out.println("It's a tie.");
				}
				else
				{
					System.out.println("You lose...1");
				}
			
			} // end finalCheck = true
		
		} // end endGame = false if
	
	} // end evaluateWin
	
} // end BlackJackGame

//==================================================================================

/**
 * Player class represents a single player in a game of Blackjack, although this class
 * could be altered for any number of games. Objects store a hand of cards, keeping
 * track of the number of cards in the hand, as well as if they have chosen to stand on
 * their turn or not.
 */
class Player
{
	/**
	 * Array holding strings corresponding to two-character notations for cards in a 52-card deck
	 */
	private String[] pCards;
	
	/**
	 * Number of cards currently in hand. 0 = 0 cards
	 */
	private int handCount;
	
	/**
	 * Boolean variable indicating if player has chosen to stand. If they chose to stand,
	 * then they can no longer hit.
	 */
	private boolean stand;
	
	/**
	 * Integer constant for maximum size of a player's hand. It is impossible for a player's hand in
	 * blackjack to be greater than 12 without busting, but for the sake of caution, the maximum
	 * hand size was set to half of a full deck of cards.
	 */
	private final int DECK_SIZE = 26;
	   
	/**
	 * Default constructor. Creates an empty array for Strings, sets handCount to 0, and stand to false.
	 */
	public Player()
	{
		pCards = new String[DECK_SIZE];
		handCount = 0;
		stand = false;
	} // end constructor
	
	/**
	 * Adds cards to the players hand by asking for a hit. Only allowable if they have no already
	 * chosen to stand. For each hit, increments handCount. The card added to the player's hand is
	 * passed as a string argument. nuCard must be in an acceptable 2-character format.
	 * @param nuCard the string argument of a card to be added to the hand
	 * @precondition assumes that nuCard originates directly from a Deck object using draw() method
	 */
	public void hit(String nuCard)
	{
		if ( !stand )
		{
			pCards[handCount] = nuCard;
			handCount++;
		}
		else
		{
			System.out.println("You cannot hit: you have already chosen to stand.");
		}
	} // end hit
	   
	/**
	 * Returns a string listing all cards currently in players hand. Accesses each array element
	 * containing a card of the current add, adding their string values to a larger string, which is
	 * then returned to the calling method. Uses the same 2-character notation they are stored in.
	 * @return a single line listing all cards currently in hand
	 */
	public String getCards()
	{
		// creates a larger string which will have the cards appended to it
		String cardList = "";
		
		// adds all cards currently in hand
		for (int i = 0; i < handCount; i++)
		{
			cardList = cardList + pCards[i] + " ";
		}
		
		return cardList;
	} // end getCards
	   
	/**
	 * Calculates total of all cards currently stored in hand. Accesses every
	 * card, adding its value to a running total. Aces are temporarily set aside
	 * and added last, as their value changes depending upon the other cards
	 * in the hand. Card values are currently set for BlackJack, and the switch
	 * is based off of the same 2-character card notation used by the Deck class.
	 * @return the total score of all cards in the hand.
	 */
	public int getTotal()
	{
		// the running total of points in the hand
		int sum = 0;

		// count of the number of aces in the hand, to be processed later
		int aces = 0;
		
		// evaluates each card in the hand
		for (int i = 0; i < handCount; i++)
		{
			int value = 0;
	
			/* while each card stores a value for both its suite and rank, this method is only
			concerned with rank, and thus only examines the first character */
			char thisCard = pCards[i].charAt(0);
			
			switch(thisCard)
			{
				case '2':	value = 2;
								break;
				case '3':	value = 3;
								break;
				case '4':	value = 4;
								break;
				case '5':	value = 5;
								break;
				case '6':	value = 6;
								break;
				case '7':	value = 7;
								break;
				case '8':	value = 8;
								break;
				case '9':	value = 9;
								break;
				case '1':	value = 10;
								break;
				case 'J':	value = 10;
								break;
				case 'Q':	value = 10;
								break;
				case 'K':	value = 10;
								break;
				case 'A':	aces++;
								value = 0;
								break;
			} // end switch
	
			sum += value;
		} // end for
		
		// checks if any aces exist
		if (aces > 0)
		{
			// The value of all aces in the hand, the first valued at 11 and all subsequent aces valued at 1
			int aceTotal = 11 + (aces - 1);
		
			/* if this total would cause the player to bust, the aces are all added at value 1.
			Otherwise, the first is added at value of 11, and the others at value of 1. */
			if ( sum <= (BlackJackGame.BUST_SCORE - aceTotal ) )
			{
				sum = sum + aceTotal;
			}
			else
			{
				sum = sum + aces;
			}
		} // end if
	
		return sum;
	} // end getTotal
	   
	/**
	 * This method resets the hand to its beginning state. Cards in the array are not erased, but the counter
	 * is reset, effectively ignoring them as there is no other way to access beyond handCount. Stand is also
	 * reset to false.
	 */
	public void resetHand()
	{
		handCount = 0;
		stand = false;
	} // end resetHand
	
	/**
	 * Used when the player chooses to stand. Sets the boolean variable stand to true.
	 */
	public void stand()
	{
		stand = true;
	} // end stand
	
	/**
	 * Access the private data member stand, returning the boolean value stored.
	 * @return the value of Stand, true if player has chosen to stand, false if not
	 */
	public boolean getStand()
	{
	return stand;
	} // end getStand
} // end Player

//=========================================================================

/**
 * This is a representation of a deck of cards, with each card being represented
 * by a 2-character code, indicating the rank and suite of each card. The class is
 * capable of shuffling the deck, as well as resetting the deck, drawing cards, and
 * reporting if the deck is empty.
 */
class Deck
{
	/**
	 * Array of strings holding representations of all 52 playing cards in a standard deck.
	 * Each card is represented by a 2-character notation indicating rank and suite.
	 */
	private String[] cards;
	
	/**
	 * The index of the top card currently in the array. If the deck is empty, topCard will
	 * be -1.
	 */
	private int topCard;
	
	/**
	 * The size of the deck, expressed as an integer. Will always be 52.
	 */
	private final int DECK_SIZE = 52;
	
	/**
	 * The name of the file containing the 2-character notations for all 52 cards in the deck.
	 */
	private final String FILE_NAME = "deck52cards.txt";
	
	/**
	 * Default constructor. Creates the array, then populates it using newDeck.
	 * @precondition The file listed in FILE_NAME must exist.
	 */
	public Deck()
	{
		cards = new String[DECK_SIZE];
		
		newDeck();
	}	// end Constructor
	
	/**
	 * Resets the deck, re-populating it with the card notations in the file, then shuffling
	 * them using the shuffle method.
	 */
	public void newDeck()
	{
		// attempts to read the file
		try
		{
			// sets up file input
			File file = new File(FILE_NAME);
			Scanner inputFile = new Scanner(file);
			
			// creates counter for array input
			int i = 0;
			
			// reads card notations from file
			while (inputFile.hasNext() && i < DECK_SIZE)
			{
				cards[i] = inputFile.nextLine();
				
				i++;
			}
	
			// Closes the file.
			inputFile.close();
			
			// Sets topCard
			topCard = 51;
			
			// shuffles deck
			shuffle();
		}
		catch (FileNotFoundException e)
		{
			// prints error if file not found
			System.out.println("The file " + FILE_NAME + " does not exist.");
		}
	}	// end populateDeck
	
	/**
	 * Shuffles the deck of cards using FIsher-Yates shuffle. Goes through entire
	 * array, randoming swapping placement of cards.
	 */
	public void shuffle()
	{
		Random rand = ThreadLocalRandom.current();
		
		for (int i = topCard; i > 0; i--)
		{
			int index = rand.nextInt(i + 1);
			String temp = cards[index];
			cards[index] = cards[i];
			cards[i] = temp;
		}
	}	// end shuffle
	
	/**
	 * Draws card from the top of the deck, removing it from the array and returning
	 * it as a string to the calling method. Decrements topCard each time this is
	 * performed. If the deck is empty, a blank string is returned.
	 * @return the top card drawn from the deck
	 */
	public String draw()
	{
		String cardToDraw = "";
		
		// Checks deck status with isEmpty method
		if ( !isEmpty() )
		{
			cardToDraw = cards[topCard];
			topCard--;
		}
		
		return cardToDraw;
	}	// end draw
	
	/**
	 * Checks if deck is empty. Returns true is deck is empty, false if still has a card.
	 * @return boolean value for if deck is empty or not
	 */
	public boolean isEmpty()
	{
		// default starting point is true
		boolean result = false;
		
		// deck is empty if top card is -1
		// 0 is the first index of the array, so 0 means there is one card remaining
		if (topCard == -1)
		{
			result = true;
		}
		
		return result;
	}	// end isEmpty
	
	/**
	 * Displays a full list of all cards in the deck, listed in four rows of thirteen cards each.
	 */
	public void getDeck()
	{
		// counter for number of cards displayed per row
		int row = 0;
		
		for (int i = 0; i <= topCard; i++)
		{
			// prints card notation
			System.out.print(cards[i] + " ");
			
			// increments row
			row++;
			
			// if the row is maxed out, moves display to next line
			if (row >= 13)
			{
				System.out.print("\n");
				row = 0;
			}
		}
		
		System.out.print("\n");
	} // end getDeck()

}	// end Deck