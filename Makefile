
RUN_ARGS := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))

drop:
	rails db:drop

up:
	rails db:create
	rails db:migrate:up VERSION=20221125221135
	rails db:migrate:up VERSION=20221126122610
	rails db:migrate:up VERSION=20221127130638
	rails db:migrate:up VERSION=20221127184240
	rails db:migrate:up VERSION=20221127190841
	rails db:migrate:up VERSION=20221128004654
	rails db:migrate:up VERSION=20221128005045
	rails db:migrate:up VERSION=20221128190635
	rails db:migrate:up VERSION=20221128220640
	rake import:from_xlsx_books
	rake import:from_xlsx_persons_trip
	rake import_fines:from_xlsx_fines
	rake import_fines:from_xlsx_traffic_violations
	rake import_payment:from_xlsx_payment
	rails db:migrate:up VERSION=20221129151710
	rails db:migrate:up VERSION=20221129154105
	rails db:migrate:up VERSION=20221129154648
	rails db:migrate:up VERSION=20221129155715
	rails db:migrate:up VERSION=20221129161125

down:
	rails db:migrate:down VERSION=20221125221135
	rails db:migrate:down VERSION=20221126122610
	rails db:migrate:down VERSION=20221127130638
	rails db:migrate:down VERSION=20221127184240
	rails db:migrate:down VERSION=20221127190841
	rails db:migrate:down VERSION=20221128004654
	rails db:migrate:down VERSION=20221128005045
	rails db:migrate:down VERSION=20221128190635
	rails db:migrate:down VERSION=20221128220640
	rails db:migrate:down VERSION=20221129151710
	rails db:migrate:down VERSION=20221129154105
	rails db:migrate:down VERSION=20221129154648
	rails db:migrate:down VERSION=20221129155715
	rails db:migrate:down VERSION=20221129161125

migration:
	bundle exec rails g migration $(RUN_ARGS)

model:
	bundle exec rails g model $(RUN_ARGS)

create:
	bundle exec rails db:create

migrate:
	bundle exec rails db:migrate

rubocop:
	rubocop -A

run-console:
	bundle exec rails console

c: run-console

.PHONY:	db
