defmodule RecipeAppWeb.CoreComponentsTest do
  use RecipeAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias RecipeAppWeb.CoreComponents

  describe "flash/1" do
    test "renders nothing when there is no flash message" do
      assert render_component(&CoreComponents.flash/1, %{kind: :info, flash: %{}}) == ""
    end

    test "renders info flash with a title and custom attributes" do
      markup =
        render_component(&CoreComponents.flash/1, %{
          kind: :info,
          flash: %{"info" => "Changes saved"},
          title: "Success",
          rest: %{"data-testid" => "flash"}
        })

      assert markup =~ ~s(id="flash-info")
      assert markup =~ ~s(data-testid="flash")
      assert markup =~ "alert-info"
      assert markup =~ "Success"
      assert markup =~ "Changes saved"
      assert markup =~ "hero-information-circle"
    end

    test "renders error flash from the inner slot" do
      markup =
        render_component(&CoreComponents.flash/1, %{
          kind: :error,
          flash: %{},
          id: "custom-error",
          inner_block: [%{inner_block: fn _assigns, _ -> "Something went wrong" end}]
        })

      assert markup =~ ~s(id="custom-error")
      assert markup =~ "alert-error"
      assert markup =~ "Something went wrong"
      assert markup =~ "hero-exclamation-circle"
    end
  end

  describe "button/1" do
    test "renders a button with default styling" do
      markup =
        render_component(&CoreComponents.button/1, %{
          rest: %{},
          inner_block: [%{inner_block: fn _assigns, _ -> "Save" end}]
        })

      assert markup =~ ~s(class="btn btn-primary btn-soft")
      assert markup =~ "<button"
      assert markup =~ "Save"
    end

    test "renders a primary button with supplied attributes" do
      markup =
        render_component(&CoreComponents.button/1, %{
          rest: %{type: "submit", disabled: true},
          variant: "primary",
          class: "btn-wide",
          inner_block: [%{inner_block: fn _assigns, _ -> "Submit" end}]
        })

      assert markup =~ ~s(class="btn-wide")
      assert markup =~ ~s(type="submit")
      assert markup =~ "disabled"
      assert markup =~ "Submit"
    end

    test "renders navigation buttons as links" do
      for navigation <- [%{href: "/recipes"}, %{navigate: "/recipes"}, %{patch: "/recipes"}] do
        markup =
          render_component(&CoreComponents.button/1, %{
            rest: navigation,
            inner_block: [%{inner_block: fn _assigns, _ -> "Recipes" end}]
          })

        assert markup =~ "<a"
        assert markup =~ "/recipes"
        assert markup =~ "Recipes"
      end
    end
  end

  describe "input/1" do
    test "renders hidden inputs" do
      markup =
        render_component(&CoreComponents.input/1, %{
          type: "hidden",
          id: "user-id",
          name: "user[id]",
          value: "42",
          rest: %{}
        })

      assert markup =~ ~s(type="hidden")
      assert markup =~ ~s(id="user-id")
      assert markup =~ ~s(name="user[id]")
      assert markup =~ ~s(value="42")
    end

    test "renders checkbox inputs with checked state and errors" do
      markup =
        render_component(&CoreComponents.input/1, %{
          type: "checkbox",
          id: "terms",
          name: "terms",
          label: "Accept terms",
          value: true,
          errors: ["must be accepted"],
          rest: %{}
        })

      assert markup =~ ~s(type="checkbox")
      assert markup =~ ~s(checked)
      assert markup =~ "Accept terms"
      assert markup =~ "must be accepted"
      assert markup =~ "hero-exclamation-circle"
      assert markup =~ ~s(value="false")
    end

    test "renders select inputs with prompt, options, and validation errors" do
      markup =
        render_component(&CoreComponents.input/1, %{
          type: "select",
          id: "country",
          name: "country",
          label: "Country",
          prompt: "Choose a country",
          options: [{"Nigeria", "ng"}, {"Ghana", "gh"}],
          value: "ng",
          errors: ["is required"],
          rest: %{}
        })

      assert markup =~ "<select"
      assert markup =~ "Country"
      assert markup =~ "Choose a country"
      assert Regex.match?(~r/<option\b(?=[^>]*value="ng")(?=[^>]*selected)[^>]*>/, markup)
      assert markup =~ "Nigeria"
      assert markup =~ "Ghana"
      assert markup =~ "select-error"
      assert markup =~ "is required"
    end

    test "renders multiple select inputs with a custom class" do
      markup =
        render_component(&CoreComponents.input/1, %{
          type: "select",
          name: "tags[]",
          multiple: true,
          options: [{"Breakfast", "breakfast"}],
          value: ["breakfast"],
          class: "custom-select",
          errors: [],
          rest: %{}
        })

      assert markup =~ ~s(multiple)
      assert markup =~ "custom-select"
      assert markup =~ "Breakfast"
    end

    test "renders textarea inputs and normalizes their value" do
      markup =
        render_component(&CoreComponents.input/1, %{
          type: "textarea",
          id: "bio",
          name: "bio",
          label: "About",
          value: "Home cook",
          errors: ["too short"],
          rest: %{rows: 4}
        })

      assert markup =~ "<textarea"
      assert markup =~ ~s(rows="4")
      assert markup =~ "About"
      assert markup =~ "Home cook"
      assert markup =~ "textarea-error"
      assert markup =~ "too short"
    end

    test "renders standard inputs with custom classes and errors" do
      markup =
        render_component(&CoreComponents.input/1, %{
          type: "email",
          id: "email",
          name: "email",
          label: "Email",
          value: "cook@example.com",
          errors: ["is invalid"],
          rest: %{required: true}
        })

      assert markup =~ ~s(type="email")
      assert markup =~ ~s(value="cook@example.com")
      assert markup =~ "Email"
      assert markup =~ "input-error"
      assert markup =~ "is invalid"
      assert markup =~ "required"
    end

    test "uses caller-provided input and error classes" do
      markup =
        render_component(&CoreComponents.input/1, %{
          type: "text",
          name: "display_name",
          value: "Nature",
          class: "custom-input",
          error_class: "custom-error",
          errors: ["invalid"],
          rest: %{}
        })

      assert markup =~ "custom-input"
      assert markup =~ "custom-error"
    end

    test "renders a Phoenix form field and appends [] for multiple fields" do
      form = Phoenix.Component.to_form(%{"emails" => "cook@example.com"}, as: :user)
      field = form[:emails]

      markup =
        render_component(&CoreComponents.input/1, %{
          field: field,
          type: "email",
          multiple: true,
          rest: %{}
        })

      assert markup =~ ~s(id="user_emails")
      assert markup =~ ~s(name="user[emails][]")
      assert markup =~ ~s(value="cook@example.com")
    end
  end

  describe "header/1" do
    test "renders title, subtitle, and action slots" do
      markup =
        render_component(&CoreComponents.header/1, %{
          inner_block: [%{inner_block: fn _assigns, _ -> "Recipes" end}],
          subtitle: [%{inner_block: fn _assigns, _ -> "Your collection" end}],
          actions: [%{inner_block: fn _assigns, _ -> "New recipe" end}]
        })

      assert markup =~ "Recipes"
      assert markup =~ "Your collection"
      assert markup =~ "New recipe"
      assert markup =~ "flex items-center justify-between"
    end

    test "renders a title without optional slots" do
      markup =
        render_component(&CoreComponents.header/1, %{
          inner_block: [%{inner_block: fn _assigns, _ -> "Ingredients" end}],
          subtitle: [],
          actions: []
        })

      assert markup =~ "Ingredients"
      refute markup =~ "flex items-center justify-between"
    end
  end

  describe "table/1 and list/1" do
    test "renders table rows, columns, row ids, and actions" do
      markup =
        render_component(&CoreComponents.table/1, %{
          id: "recipes",
          rows: [%{id: 1, name: "Jollof"}, %{id: 2, name: "Egusi"}],
          row_id: &"recipe-#{&1.id}",
          row_click: fn row ->
            %Phoenix.LiveView.JS{} |> Phoenix.LiveView.JS.push("select", value: %{id: row.id})
          end,
          col: [
            %{
              label: "Name",
              inner_block: fn _assigns, row -> row.name end
            }
          ],
          action: [
            %{inner_block: fn _assigns, row -> "Edit #{row.id}" end}
          ]
        })

      assert markup =~ ~s(<tbody id="recipes")
      assert markup =~ ~s(id="recipe-1")
      assert markup =~ ~s(id="recipe-2")
      assert markup =~ "Jollof"
      assert markup =~ "Egusi"
      assert markup =~ "Edit 1"
      assert markup =~ "Edit 2"
      assert markup =~ "hover:cursor-pointer"
    end

    test "renders tables without action or row click slots" do
      markup =
        render_component(&CoreComponents.table/1, %{
          id: "empty",
          rows: [],
          col: [%{label: "Name", inner_block: fn _assigns, _row -> "" end}],
          action: []
        })

      assert markup =~ ~s(<tbody id="empty")
      assert markup =~ "<th>Name</th>"
      refute markup =~ "hover:cursor-pointer"
    end

    test "renders list items" do
      markup =
        render_component(&CoreComponents.list/1, %{
          item: [
            %{title: "Prep time", inner_block: fn _assigns, _ -> "15 minutes" end},
            %{title: "Cook time", inner_block: fn _assigns, _ -> "30 minutes" end}
          ]
        })

      assert markup =~ "Prep time"
      assert markup =~ "15 minutes"
      assert markup =~ "Cook time"
      assert markup =~ "30 minutes"
    end
  end

  test "renders hero icons with the supplied class" do
    markup = render_component(&CoreComponents.icon/1, %{name: "hero-fire", class: "size-8"})
    assert markup =~ "hero-fire"
    assert markup =~ "size-8"
  end

  test "show and hide return JavaScript commands" do
    assert %Phoenix.LiveView.JS{} = CoreComponents.show("#dialog")
    assert %Phoenix.LiveView.JS{} = CoreComponents.hide("#dialog")
    assert %Phoenix.LiveView.JS{} = CoreComponents.show(%Phoenix.LiveView.JS{}, "#dialog")
    assert %Phoenix.LiveView.JS{} = CoreComponents.hide(%Phoenix.LiveView.JS{}, "#dialog")
  end

  test "translates singular and plural validation messages" do
    assert is_binary(CoreComponents.translate_error({"is invalid", []}))
    assert is_binary(CoreComponents.translate_error({"%{count} item", count: 2}))

    assert CoreComponents.translate_errors(
             [email: {"is invalid", []}, name: {"can't be blank", []}],
             :email
           ) ==
             [CoreComponents.translate_error({"is invalid", []})]

    assert CoreComponents.translate_errors([], :email) == []
  end
end
