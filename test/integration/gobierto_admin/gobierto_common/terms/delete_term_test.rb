# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  module GobiertoAdmin
    class DeleteTermTest < ActionDispatch::IntegrationTest

      def setup
        super
        @path = admin_common_vocabulary_terms_path(vocabulary)
      end

      def vocabulary
        gobierto_common_vocabularies(:issues_vocabulary)
      end

      def admin
        @admin ||= gobierto_admin_admins(:tony)
      end

      def unauthorized_admin
        @unauthorized_admin ||= gobierto_admin_admins(:steve)
      end

      def site
        @site ||= sites(:madrid)
      end

      def term
        @term ||= gobierto_common_terms(:sports_term)
      end

      def term_with_associated_items
        @term_with_associated_items ||= gobierto_common_terms(:culture_term)
      end

      def plan_vocabulary
        @plan_vocabulary ||= gobierto_common_vocabularies(:plan_categories_vocabulary)
      end

      def plan_vocabulary_path
        @plan_vocabulary_path ||= admin_common_vocabulary_terms_path(plan_vocabulary)
      end

      def term_in_plan_with_nodes
        @term_in_plan_with_nodes ||= gobierto_common_terms(:people_and_families_plan_term)
      end

      def term_in_plan_without_nodes
        @term_in_plan_without_nodes ||= gobierto_common_terms(:economy_plan_term)
      end

      def test_permissions
        with_signed_in_admin(unauthorized_admin) do
          with_current_site(site) do
            visit @path
            assert has_content?("You are not authorized to perform this action")
            assert_equal admin_root_path, current_path
          end
        end
      end

      def test_delete_term
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "#term-item-#{term.id}" do
              find("a[data-method='delete']").click
            end

            assert has_message?("Term deleted successfully.")

            refute vocabulary.terms.exists?(id: term.id)
          end
        end
      end

      def test_delete_term_with_associated_items
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within "#term-item-#{term_with_associated_items.id}" do
              find("a[data-method='delete']").click
            end

            assert has_message?("You can't delete a term while it has associated elements.")

            assert vocabulary.terms.exists?(id: term_with_associated_items.id)
          end
        end
      end

      def test_delete_term_in_plan_vocabulary_with_nodes
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit plan_vocabulary_path

            within "#term-item-#{term_in_plan_with_nodes.id}" do
              find("a[data-method='delete']").click
            end

            assert has_message?("You can't delete a term while it has associated elements.")

            assert plan_vocabulary.terms.exists?(id: term_in_plan_with_nodes.id)
          end
        end
      end

      def test_delete_term_in_plan_vocabulary_without_nodes
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit plan_vocabulary_path

            within "#term-item-#{term_in_plan_without_nodes.id}" do
              find("a[data-method='delete']").click
            end

            assert has_message?("Term deleted successfully.")

            refute plan_vocabulary.terms.exists?(id: term_in_plan_without_nodes.id)
          end
        end
      end
    end
  end
end
