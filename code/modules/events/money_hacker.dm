/var/global/account_hack_attempted = 0

/datum/event/money_hacker
	var/datum/money_account/affected_account
	endWhen = 100
	var/end_time

/datum/event/money_hacker/setup()
	end_time = world.time + 6000
	if(all_money_accounts.len)
		affected_account = pick(all_money_accounts)

		account_hack_attempted = 1
	else
		kill()

/datum/event/money_hacker/announce()
	// Hide the account number for now since it's all you need to access a standard-security account. Change when that's no longer the case.
	var/accnr_hidden = "***[copytext("[affected_account.account_number]", -3)]"
	var/message = "A brute force hack has been detected (in progress since [stationtime2text()]). The target of the attack is: Financial account #[accnr_hidden], \
	without intervention this attack will succeed in approximately 10 minutes. Required intervention: temporary suspension of affected accounts until the attack has ceased. \
	Notifications will be sent as updates occur."
	command_announcement.Announce(message, "[location_name()] Firewall Subroutines")


/datum/event/money_hacker/tick()
	if(world.time >= end_time)
		endWhen = activeFor
	else
		endWhen = activeFor + 10

/datum/event/money_hacker/end()
	var/message
	if(affected_account && !affected_account.suspended)
		//hacker wins
		message = "The hack attempt has succeeded."

		//subtract the money
		var/lost = affected_account.money * 0.8 + (rand(2,4) - 2) / 10

		//create a taunting log entry
		var/datum/transaction/T = new()
		T.target_name = pick("","yo brotha from anotha motha","el Presidente","chieF smackDowN")
		T.purpose = pick("Ne$ ---ount fu%ds init*&lisat@*n","PAY BACK YOUR MUM","Funds withdrawal","pWnAgE","l33t hax","liberationez")
		T.amount = -lost
		var/date1 = "31 December, 1999"
		var/date2 = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [rand(1000,3000)]"
		T.date = pick("", stationdate2text(), date1, date2)
		var/time1 = rand(0, 99999999)
		var/time2 = "[round(time1 / 36000)+12]:[(time1 / 600 % 60) < 10 ? add_zero(time1 / 600 % 60, 1) : time1 / 600 % 60]"
		T.time = pick("", stationtime2text(), time2)
		T.source_terminal = pick("","[pick("Biesel","New Gibson")] GalaxyNet Terminal #[rand(111,999)]","your mums place","nantrasen high CommanD")

		affected_account.do_transaction(T)

	else
		//crew wins
		message = "The attack has ceased, the affected accounts can now be brought online."
	command_announcement.Announce(message, "[location_name()] Firewall Subroutines")
